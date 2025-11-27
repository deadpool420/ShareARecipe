//
//  PublicProfileView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI
import FirebaseFirestore

struct PublicProfileView: View {
    let userID: String

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    @State private var publicProfile: UserProfile?
    
    private var filteredPosts: [Recipe] {
        recipeVM.recipes.filter { $0.authorID == userID }
    }

    var isFollowing: Bool {
        authVM.userProfile?.following.contains(userID) ?? false
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                profileHeader
                profileInfo
                followersFollowingRow
                followButton

                Divider().padding(.vertical, 6)

                postsSection
            }
            .padding(.top, 20)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPublicProfile()
            recipeVM.fetchRecipes()
        }
    }

    // MARK: LOAD PUBLIC PROFILE
    private func loadPublicProfile() async {
        do {
            let doc = try await FirebaseManager.shared.db
                .collection("users")
                .document(userID)
                .getDocument()

            if let data = doc.data() {

                let profile = UserProfile(
                    uid: data["uid"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? "",
                    username: data["username"] as? String ?? "",
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
                    self.publicProfile = profile
                }
            }
        } catch {
            print("Error loading public profile:", error.localizedDescription)
        }
    }

    // PROFILE PHOTO
    private var profileHeader: some View {
        Group {
            if let base64 = publicProfile?.profileImageBase64,
               let data = Data(base64Encoded: base64),
               let img = UIImage(data: data) {

                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(radius: 4)

            } else {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .overlay(Text("No Photo").foregroundColor(.gray))
            }
        }
    }

    // PROFILE INFO
    private var profileInfo: some View {
        VStack(spacing: 10) {

            Text(publicProfile?.displayName ?? "Unknown User")
                .font(.title2).fontWeight(.bold)

            if let username = publicProfile?.username {
                Text("@\(username)").foregroundColor(.gray)
            }

            if let bio = publicProfile?.bio, !bio.isEmpty {
                Text(bio)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 10) {
                if let location = publicProfile?.location {
                    Text(" \(location)").foregroundColor(.gray)
                }
                if let birthday = publicProfile?.birthday {
                    Text(" \(birthday)").foregroundColor(.gray)
                }
            }
        }
    }

    // FOLLOWERS & FOLOWING
    private var followersFollowingRow: some View {
        HStack(spacing: 40) {

            NavigationLink(
                destination: FollowersListView(
                    userIDs: publicProfile?.followers ?? []
                )
                .environmentObject(authVM)
            ) {
                VStack {
                    Text("\(publicProfile?.followers.count ?? 0)")
                        .font(.headline)
                    Text("Followers")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }

            NavigationLink(
                destination: FollowingListView(
                    userIDs: publicProfile?.following ?? []
                )
                .environmentObject(authVM)
            ) {
                VStack {
                    Text("\(publicProfile?.following.count ?? 0)")
                        .font(.headline)
                    Text("Following")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
            }
        }
        .padding(.top, 8)
    }

    // FOLLOW BUTTON
    private var followButton: some View {
        Button {
            Task { await authVM.toggleFollow(targetUserID: userID) }
        } label: {
            Text(isFollowing ? "Following" : "Follow")
                .fontWeight(.semibold)
                .foregroundColor(isFollowing ? .white : .orange)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFollowing ? Color.orange : Color.orange.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.horizontal)
        .disabled(userID == authVM.user?.uid)
    }

    // POSTS SECTION
    private var postsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Posts")
                .font(.title3.bold())
                .padding(.horizontal)

            if filteredPosts.isEmpty {
                Text("No posts yet")
                    .foregroundColor(.gray)
                    .padding(.top)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {

                    ForEach(filteredPosts) { recipe in
                        NavigationLink(
                            destination: RecipeDetailView(recipe: recipe)
                        ) {
                            GridThumbnail(recipe: recipe)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
}
