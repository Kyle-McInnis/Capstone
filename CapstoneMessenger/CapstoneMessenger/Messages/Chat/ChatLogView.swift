//
//  ChatLogView.swift
//  CapstoneMessenger
//
//  Created by Kyle McInnis on 2022-02-24.
//

import SwiftUI
import Firebase
import simd

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    // Shows the messages that have been sent in the chat log
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
        firestoreListener = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                // Prevents previous messages from repeating every time a new message is sent
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    // Handles sending a text message to another user
    func handleSend() {
        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
         let document =
            FirebaseManager.shared.firestore
            .collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
            
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Recipent saved message as well")
        }
        
    }
    
    // Save recent messages within the chat log view screen
    private func persistRecentMessage() {
        guard let chatUser = chatUser else { return }
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        
        guard let toId = self.chatUser?.uid else {return}
        
         let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recent_messages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)
        
        // Data dictionary for user, includes what information is being saved to chat log view
        let data = [
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        document.setData(data) { error in
            if let error = error {
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
                let recipientRecentMessageDictionary = [
                    FirebaseConstants.text: self.chatText,
                    FirebaseConstants.fromId: uid,
                    FirebaseConstants.toId: toId,
                    FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
                    FirebaseConstants.email: currentUser.email
                ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recent_messages)
                    .document(toId)
                    .collection(FirebaseConstants.messages)
                    .document(currentUser.uid)
                    .setData(recipientRecentMessageDictionary) { error in
                        if let error = error {
                            print("Failed to save recipient recent message: \(error)")
                            return
                        }
                    }
    }
    
    @Published var count = 0
}

struct ChatLogView: View {
    
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
        ZStack {
            messageView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
    }
    
    static let emptyScrollToString = "Empty"
    
    private var messageView: some View {
        ScrollView {
            ScrollViewReader { ScrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    
                    HStack { Spacer() }
                    .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        ScrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                    
                }
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
            chatBar
                .background(Color(.systemBackground).ignoresSafeArea())
        }
    }
    
    @State var showImagePicker = false
    
    private var chatBar: some View {
        
        HStack(spacing: 16) {
            Button {
                showImagePicker
                    .toggle()
            } label: {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
            }
            ZStack {
                if let image = self.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                }
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)

            Button {
                vm.handleSend()
            } label: {
                Image(systemName: "arrow.up.message")
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.purple)
            .cornerRadius(16)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
}


struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(32)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(32)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 2)
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
//            ChatLogView(chatUser: .init(data: ["uid": "vFztfLF26pg9xcNyHD61YmUlHTH3", "email": "kyletest1@gmail.com"]))
        }
        
    }
}
