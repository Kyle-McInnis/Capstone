//
//  FirebaseManager.swift
//  CapstoneMessenger
//
//  Created by Kyle McInnis on 2022-02-15.
//

import Foundation
import Firebase
import FirebaseFirestore


// Allows access to the information stored in the firebase application to be used in the app.
class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage: Storage
    let firestore: Firestore
    
    var currentUser: ChatUser?
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
}
