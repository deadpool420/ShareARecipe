//
//  CommentViewModel.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import Foundation
import FirebaseFirestore

@MainActor
final class CommentViewModel: ObservableObject {

    @Published var commentText: String = ""
    @Published var comments: [RecipeComment] = []

    private let db = FirebaseManager.shared.db
    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func listenComments(recipeID: String) {
        listener?.remove()

        listener = db.collection("recipes").document(recipeID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self,
                      let data = snapshot?.data() else { return }

                guard let commentArray = data["comments"] as? [[String: Any]] else {
                    self.comments = []
                    return
                }

                self.comments = commentArray.compactMap { item in
                    let id = item["id"] as? String ?? UUID().uuidString
                    let userID = item["userID"] as? String ?? ""
                    let userName = item["userName"] as? String ?? "Unknown"
                    let text = item["text"] as? String ?? ""
                    let createdAt = (item["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    let userImageBase64 = item["userImageBase64"] as? String

                    return RecipeComment(
                        id: id,
                        userID: userID,
                        userName: userName,
                        text: text,
                        createdAt: createdAt,
                        userImageBase64: (userImageBase64?.isEmpty == true) ? nil : userImageBase64
                    )
                }
                .sorted(by: { $0.createdAt < $1.createdAt })  // oldest first
            }
    }

    func addComment(
        to recipeID: String,
        userID: String,
        userName: String,
        userImageBase64: String?
    ) async {

        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newComment = RecipeComment(
            userID: userID,
            userName: userName,
            text: trimmed,
            createdAt: Date(),
            userImageBase64: userImageBase64
        )

        let data: [String: Any] = [
            "id": newComment.id,
            "userID": newComment.userID,
            "userName": newComment.userName,
            "text": newComment.text,
            "createdAt": Timestamp(date: newComment.createdAt),
            "userImageBase64": newComment.userImageBase64 ?? ""
        ]

        do {
            try await db.collection("recipes")
                .document(recipeID)
                .updateData([
                    "comments": FieldValue.arrayUnion([data])
                ])

            self.commentText = ""

        } catch {
            print("Failed to add comment: \(error.localizedDescription)")
        }
    }
}
