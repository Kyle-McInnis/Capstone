//
//  ChatLogView.swift
//  CapstoneMessenger
//
//  Created by Kyle McInnis on 2022-02-24.
//

import SwiftUI

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    @State var chatText = ""
    
    var body: some View {
        ZStack {
            messageView
            VStack {
                Spacer()
                chatBar
                    .background(Color.white.ignoresSafeArea())
            }
            
        }
        
        .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    private var messageView: some View {
        ScrollView {
            ForEach(0..<20) { num in
                HStack {
                    Spacer()
                    HStack {
                        Text("Hello, this is a test message")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(32)
                }
                .padding(.horizontal)
                .padding(.top, 2)
                
                
            }
            
            HStack { Spacer() }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .padding(.bottom, 65)
    }
    
    private var chatBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)

            Button {
                
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
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatLogView(chatUser: .init(data: ["uid": "vFztfLF26pg9xcNyHD61YmUlHTH3", "email": "kyletest1@gmail.com"]))
        }
        
    }
}
