//
//  RecipeCardView.swift
//  ShareARecipe
//
//  Modern UI with iOS 17 Navigation
//


import SwiftUI

struct RecipeCardView: View {

    let recipe: Recipe
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var commentVM: CommentViewModel

    @State private var goToPublicProfile = false
    @State private var goToUserProfile = false

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack(spacing: 12) {

                profileImage
                    .onTapGesture { handleProfileTap() }

                VStack(alignment: .leading) {
                    Text(recipe.authorName)
                        .font(.headline)
                        .onTapGesture { handleProfileTap() }

                    Text(timeAgoSince(recipe.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button {
                    if let uid = authVM.user?.uid {
                        recipeVM.toggleSave(recipe, userID: uid)
                    }
                } label: {
                    Image(systemName:
                            recipe.savedBy.contains(authVM.user?.uid ?? "") ?
                            "bookmark.fill" : "bookmark")
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)

            if let base64 = recipe.base64Image,
               let data = Data(base64Encoded: base64),
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxHeight: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(radius: 3)
                    .padding(.horizontal, 8)
            }

            Text(recipe.title)
                .font(.title3.bold())
                .padding(.horizontal)

            HStack(spacing: 16) {

                let uid = authVM.user?.uid ?? ""

                // UPVOTE
                Button {
                    recipeVM.vote(recipe: recipe, upvote: true)
                } label: {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(recipe.upvoters.contains(uid) ? .orange : .gray)
                }

                // DOWNVOTE
                Button {
                    recipeVM.vote(recipe: recipe, upvote: false)
                } label: {
                    Image(systemName: "hand.thumbsdown")
                        .foregroundColor(recipe.downvoters.contains(uid) ? .blue : .gray)
                }

                Text("Score: \(recipe.score)")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                        .environmentObject(authVM)
                        .environmentObject(commentVM)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                        Text("Comments")
                    }
                    .font(.subheadline)
                }
            }
            .padding(.horizontal)

        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal)

        .navigationDestination(isPresented: $goToUserProfile) {
            ProfileView()
                .environmentObject(authVM)
                .environmentObject(recipeVM)
                .environmentObject(commentVM)
        }
        .navigationDestination(isPresented: $goToPublicProfile) {
            PublicProfileView(userID: recipe.authorID)
                .environmentObject(authVM)
                .environmentObject(recipeVM)
                .environmentObject(commentVM)
        }
    }

    private func handleProfileTap() {
        if recipe.authorID == authVM.user?.uid {
            goToUserProfile = true   // Go to own profile
        } else {
            goToPublicProfile = true // Go to someone else's profile
        }
    }

    private var profileImage: some View {
        Group {
            if let base64 = recipe.authorImageBase64,
               let data = Data(base64Encoded: base64),
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())

            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 42, height: 42)
                    .overlay(Image(systemName: "person.fill"))
            }
        }
    }
}
