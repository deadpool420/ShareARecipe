//
//  CommentSheetView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/22/25.
//


import SwiftUI

struct CommentSheetView: View {

    let recipe: Recipe

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var commentVM: CommentViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {

            Text("Comments")
                .font(.title3.bold())
                .padding(.vertical, 12)

            Divider()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        ForEach(commentVM.comments) { comment in
                            commentRow(comment)
                                .id(comment.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .onChange(of: commentVM.comments.count) { _ in
                    if let last = commentVM.comments.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Write a comment...", text: pressureSafeTextBinding(), axis: .vertical)
                    .lineLimit(1...4)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($isFocused)

                Button(action: sendComment) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.orange)
                }
                .disabled(commentVM.commentText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
        }
        .onAppear {
            commentVM.listenComments(recipeID: recipe.id)
        }
    }

    private func pressureSafeTextBinding() -> Binding<String> {
        Binding(
            get: { commentVM.commentText },
            set: { newValue in commentVM.commentText = String(newValue.prefix(500)) }
        )
    }

	    private var userAvatar: some View {
        Group {
            if let base64 = authVM.userProfile?.profileImageBase64,
               let data = Data(base64Encoded: base64),
               let img = UIImage(data: data) {

                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 38, height: 38)
                    .clipShape(Circle())

            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 38, height: 38)
                    .overlay(Image(systemName: "person.fill"))
            }
        }
    }

    private func commentRow(_ comment: RecipeComment) -> some View {
        HStack(alignment: .top, spacing: 12) {

            if let base64 = comment.userImageBase64,
               let data = Data(base64Encoded: base64),
               let img = UIImage(data: data) {

                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())

            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 42, height: 42)
                    .overlay(Image(systemName: "person.fill").foregroundColor(.white))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(comment.userName)
                    .font(.headline)

                Text(comment.text)
                    .font(.body)

                Text(timeAgoSince(comment.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
    }

    private func sendComment() {
        Task {
            await commentVM.addComment(
                to: recipe.id,
                userID: authVM.user?.uid ?? "",
                userName: authVM.userProfile?.displayName ?? "Unknown",
                userImageBase64: authVM.userProfile?.profileImageBase64
            )

            recipeVM.fetchRecipes()

            // Clear input field
            commentVM.commentText = ""
        }
    }
}
