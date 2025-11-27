//
//  FirebaseManager.swift
//  ShareARecipe
//
//  Created by user286005 on 11/10/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager {
    static let shared = FirebaseManager()

    let auth: Auth
    let db: Firestore
    let storage: Storage

    private init() {
        self.auth = Auth.auth()
        self.db = Firestore.firestore()
        self.storage = Storage.storage()
    }
}
