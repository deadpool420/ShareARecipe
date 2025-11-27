//
//  FullScreenRecipeView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/17/25.
//


import SwiftUI

struct FullScreenRecipeView: View {

    let recipe: Recipe

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var commentVM: CommentViewModel
    @EnvironmentObject var groceryVM: GroceryViewModel

    @State private var showComments = false
    @State private var showGroceryToast = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    if let base64 = recipe.base64Image,
                       let data = Data(base64Encoded: base64),
                       let img = UIImage(data: data) {

                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 260)
                            .clipped()

                    } else {
                        Rectangle()
                            .fill(Color(.systemGray6))
                            .frame(height: 260)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {

                        Text(recipe.title)
                            .font(.title)
                            .fontWeight(.bold)

                        HStack(spacing: 8) {
                            Text("by \(recipe.authorName)")
                                .foregroundColor(.gray)
                                .font(.subheadline)

                            Text("• \(recipe.category)")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }

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

                            if let uid = authVM.user?.uid {
                                Button {
                                    recipeVM.toggleSave(recipe, userID: uid)
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: recipe.savedBy.contains(uid) ? "bookmark.fill" : "bookmark")
                                        Text(recipe.savedBy.contains(uid) ? "Saved" : "Save")
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.15))
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.top, 4)

                        Button {
                            showComments = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "bubble.right")
                                Text("View comments (\(recipe.commentCount ?? 0))")
                            }
                            .font(.subheadline)
                        }
                        .padding(.top, 4)

                        Button {
                            if let uid = authVM.user?.uid {
                                Task {
                                    await groceryVM.createListFromRecipe(recipe: recipe, userID: uid)
                                    withAnimation {
                                        showGroceryToast = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { showGroceryToast = false }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "cart.badge.plus")
                                Text("Add ingredients to grocery list")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        .padding(.top, 6)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ingredients")
                            .font(.headline)
                        Text(recipe.ingredients)
                            .font(.body)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Steps")
                            .font(.headline)
                        Text(recipe.steps)
                            .font(.body)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 30)
                }
            }
            .navigationTitle("Recipe")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }

            .sheet(isPresented: $showComments) {
                CommentSheetView(recipe: recipe)
                    .environmentObject(authVM)
                    .environmentObject(commentVM)
            }

            .overlay(alignment: .top) {
                if showGroceryToast {
                    Text("Added to your grocery list ")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            .onAppear {
                recipeVM.fetchRecipes()
            }
        }
    }
}

