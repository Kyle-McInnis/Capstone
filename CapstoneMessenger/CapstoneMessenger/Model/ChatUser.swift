//
//  ChatUser.swift
//  CapstoneMessenger
//
//  Created by Kyle McInnis on 2022-02-17.
//

import Foundation

// Information about the chat user has their uid, email, and profile imaged stored. Used when fethching user information when logging in.
struct ChatUser: Identifiable {
    
    var id: String { uid }
    
    let uid, email, profileImageUrl: String
    
    
    // Finds the uid, email, and profileImageUrl string data. If it does not find that data, it will come back with an empty string instead.
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
