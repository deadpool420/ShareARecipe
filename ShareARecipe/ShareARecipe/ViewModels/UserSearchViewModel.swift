//
//  UserSearchViewModel.swift
//  ShareARecipe
//
//  Created by user286005 on 11/23/25.
//


import Foundation
import FirebaseFirestore

@MainActor
class UserSearchViewModel: ObservableObject {

    @Published var allUsers: [UserProfile] = []

    private let db = FirebaseManager.shared.db

    func fetchAllUsers() {
        db.collection("users").addSnapshotListener { snapshot, error in
            guard let docs = snapshot?.documents else { return }

            self.allUsers = docs.compactMap { doc in
                try? doc.data(as: UserProfile.self)
            }
        }
    }
}

