//
//  RecentMessage.swift
//  CapstoneMessenger
//
//  Created by Kyle McInnis on 2022-03-24.
//

import Foundation
import Firebase

struct RecentMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let text, fromId, toId: String
    let email, profileImageUrl: String
    
    init(documentId: String, data: [String: Any]) {
            self.documentId = documentId
            self.text = data[FirebaseConstants.text] as? String ?? ""
            self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
            self.toId = data[FirebaseConstants.toId] as? String ?? ""
            self.profileImageUrl = data[FirebaseConstants.profileImageUrl] as? String ?? ""
            self.email = data[FirebaseConstants.email] as? String ?? ""
        }
}
