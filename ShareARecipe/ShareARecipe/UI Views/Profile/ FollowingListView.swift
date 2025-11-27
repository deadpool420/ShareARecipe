//
//   FollowingListView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/22/25.
//

import SwiftUI

struct FollowingListView: View {

    let userIDs: [String]

    @EnvironmentObject var authVM: AuthViewModel
    @State private var users: [UserProfile] = []

    var body: some View {
        List(users, id: \.uid) { user in
            NavigationLink(destination: PublicProfileView(userID: user.uid)) {
                HStack(spacing: 12) {

                    if let base64 = user.profileImageBase64,
                       let data = Data(base64Encoded: base64),
                       let img = UIImage(data: data) {

                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())

                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 48, height: 48)
                            .overlay(Image(systemName: "person.fill"))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.displayName).font(.headline)
                        if let username = user.username {
                            Text("@\(username)").font(.caption).foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    Button {
                        Task { await authVM.toggleFollow(targetUserID: user.uid) }
                    } label: {
                        Text(authVM.userProfile?.following.contains(user.uid) == true
                             ? "Following"
                             : "Follow")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .navigationTitle("Following")
        .onAppear { loadUsers() }
    }

    private func loadUsers() {
        Task {
            var loaded: [UserProfile] = []

            for id in userIDs {
                let doc = try? await FirebaseManager.shared.db.collection("users")
                    .document(id).getDocument()

                if let data = doc?.data() {
                    let profile = UserProfile(
                        uid: data["uid"] as? String ?? id,
                        displayName: data["displayName"] as? String ?? "",
                        username: data["username"] as? String,
                        email: data["email"] as? String ?? "",
                        profileImageBase64: data["profileImageBase64"] as? String,
                        birthday: data["birthday"] as? String,
                        bio: data["bio"] as? String,
                        location: data["location"] as? String,
                        followers: data["followers"] as? [String] ?? [],
                        following: data["following"] as? [String] ?? [],
                        createdAt: Date()
                    )
                    loaded.append(profile)
                }
            }

            await MainActor.run { users = loaded }
        }
    }
}
