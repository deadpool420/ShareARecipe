//
//  AuthViewModel.swift
//  ShareARecipe
//
//  Created by user286005 on 11/10/25.


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {

    @Published var user: User?
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let db = FirebaseManager.shared.db

    init() {
        user = Auth.auth().currentUser
        if user != nil {
            Task { await fetchUserProfile() }
        }
    }

    // REGISTER USER

    func register(email: String, password: String, displayName: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await Auth.auth().createUser(
                withEmail: email,
                password: password
            )

            user = result.user

            let profile = UserProfile(
                uid: result.user.uid,
                displayName: displayName,
                username: displayName.lowercased().replacingOccurrences(of: " ", with: ""),
                email: email,
                profileImageBase64: nil,
                birthday: nil,
                bio: nil,
                location: nil,
                followers: [],
                following: [],
                createdAt: Date()
            )

            try db.collection("users")
                .document(result.user.uid)
                .setData(from: profile)

            await fetchUserProfile()

        } catch {
            errorMessage = error.localizedDescription
            print("Registration error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    // LOGIN

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            user = result.user
            await fetchUserProfile()

        } catch {
            errorMessage = error.localizedDescription
            print("Login error:", error.localizedDescription)
        }

        isLoading = false
    }

    // FETCH USER PROFILE

    func fetchUserProfile() async {
        guard let uid = user?.uid else { return }

        do {
            let snapshot = try await db.collection("users")
                .document(uid)
                .getDocument()

            guard var data = snapshot.data() else { return }

            func clean(_ key: String) {
                if let value = data[key] as? String,
                   value.trimmingCharacters(in: .whitespaces).isEmpty {
                    data[key] = nil
                }
            }

            ["bio", "birthday", "location", "profileImageBase64"].forEach(clean)

            let profile = UserProfile(
                uid: data["uid"] as? String ?? uid,
                displayName: data["displayName"] as? String ?? "",
                username: data["username"] as? String,
                email: data["email"] as? String ?? "",
                profileImageBase64: data["profileImageBase64"] as? String,
                birthday: data["birthday"] as? String,
                bio: data["bio"] as? String,
                location: data["location"] as? String,
                followers: data["followers"] as? [String] ?? [],
                following: data["following"] as? [String] ?? [],
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )

            await MainActor.run {
                self.userProfile = profile
            }

        } catch {
            print("Fetch profile error:", error.localizedDescription)
        }
    }

    // LOGOUT

    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
            userProfile = nil
        } catch {
            print("Sign-out error:", error.localizedDescription)
        }
    }

    //  FOLLOW /UNFOLLOW

    func toggleFollow(targetUserID: String) async {
        guard let myID = user?.uid else { return }

        let myRef = db.collection("users").document(myID)
        let targetRef = db.collection("users").document(targetUserID)

        let isFollowing = userProfile?.following.contains(targetUserID) ?? false

        do {
            if isFollowing {
                try await myRef.updateData([
                    "following": FieldValue.arrayRemove([targetUserID])
                ])
                try await targetRef.updateData([
                    "followers": FieldValue.arrayRemove([myID])
                ])
            } else {
                try await myRef.updateData([
                    "following": FieldValue.arrayUnion([targetUserID])
                ])
                try await targetRef.updateData([
                    "followers": FieldValue.arrayUnion([myID])
                ])
            }

            await fetchUserProfile()

        } catch {
            print("Follow/Unfollow error:", error.localizedDescription)
        }
    }

    // UPDATE PROFILE

    func updateProfile(
        displayName: String,
        username: String?,
        profileImageBase64: String?,
        bio: String?,
        birthday: String?,
        location: String?
    ) async {
        guard let uid = user?.uid else { return }

        isLoading = true
        errorMessage = nil

        var data: [String: Any] = [
            "displayName": displayName
        ]

        if let username = username, !username.isEmpty {
            data["username"] = username
        }

        if let image = profileImageBase64, !image.isEmpty {
            data["profileImageBase64"] = image
        } else {
            data["profileImageBase64"] = FieldValue.delete()
        }

        if let bio = bio, !bio.isEmpty {
            data["bio"] = bio
        } else {
            data["bio"] = FieldValue.delete()
        }

        if let birthday = birthday, !birthday.isEmpty {
            data["birthday"] = birthday
        } else {
            data["birthday"] = FieldValue.delete()
        }

        if let location = location, !location.isEmpty {
            data["location"] = location
        } else {
            data["location"] = FieldValue.delete()
        }

        do {
            try await db.collection("users")
                .document(uid)
                .updateData(data)

            await fetchUserProfile()

        } catch {
            errorMessage = error.localizedDescription
            print("Update profile error:", error.localizedDescription)
        }

        isLoading = false
    }
}
