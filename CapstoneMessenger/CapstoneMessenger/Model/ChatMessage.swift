//
//  ChatMessage.swift
//  CapstoneMessenger
//
//  Created by Kyle McInnis on 2022-03-24.
//

import Foundation
import Firebase

// Identifying the text message that is send, who sent the message, and who it is being sent to.
struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text, email, profileImageUrl: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
        self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
        self.email = data[FirebaseConstants.email] as? String ?? ""
    }
}
