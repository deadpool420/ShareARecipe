//
//  RecipeViewModel.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class RecipeViewModel: ObservableObject {

    @Published var recipes: [Recipe] = []

    private let db = FirebaseManager.shared.db

    func fetchRecipes() {
        db.collection("recipes")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching recipes:", error.localizedDescription)
                    return
                }

                guard let docs = snapshot?.documents else { return }

                self.recipes = docs.compactMap { doc in
                    let data = doc.data()

                    let id = doc.documentID
                    let title = data["title"] as? String ?? ""
                    let ingredients = data["ingredients"] as? String ?? ""
                    let steps = data["steps"] as? String ?? ""
                    let base64Image = data["base64Image"] as? String
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()

                    let authorID = data["authorID"] as? String ?? ""
                    let authorName = data["authorName"] as? String ?? "Unknown"
                    let authorImageBase64 = data["authorImageBase64"] as? String

                    let savedBy = data["savedBy"] as? [String] ?? []

                    let upvoters = data["upvoters"] as? [String] ?? []
                    let downvoters = data["downvoters"] as? [String] ?? []

                    let category = data["category"] as? String ?? "Other"

                    let commentArray = data["comments"] as? [[String: Any]] ?? []
                    let commentCount = commentArray.count

                    return Recipe(
                        id: id,
                        title: title,
                        ingredients: ingredients,
                        steps: steps,
                        base64Image: base64Image,
                        createdAt: createdAt,
                        authorID: authorID,
                        authorName: authorName,
                        authorImageBase64: authorImageBase64,
                        savedBy: savedBy,
                        upvoters: upvoters,
                        downvoters: downvoters,
                        category: category,
                        commentCount: commentCount
                    )
                }
            }
    }

    func addRecipe(_ recipe: Recipe) async {
        let data: [String: Any] = [
            "id": recipe.id,
            "title": recipe.title,
            "ingredients": recipe.ingredients,
            "steps": recipe.steps,
            "base64Image": recipe.base64Image as Any,
            "createdAt": Timestamp(date: recipe.createdAt),
            "authorID": recipe.authorID,
            "authorName": recipe.authorName,
            "authorImageBase64": recipe.authorImageBase64 as Any,
            "savedBy": recipe.savedBy,
            "upvoters": recipe.upvoters,
            "downvoters": recipe.downvoters,
            "category": recipe.category,
            "comments": []
        ]

        do {
            try await db.collection("recipes").document(recipe.id).setData(data)
        } catch {
            print("Error adding recipe:", error.localizedDescription)
        }
    }

    func updateRecipe(recipe: Recipe) async {
        let data: [String: Any] = [
            "title": recipe.title,
            "ingredients": recipe.ingredients,
            "steps": recipe.steps,
            "base64Image": recipe.base64Image as Any,
            "category": recipe.category
        ]

        do {
            try await db.collection("recipes").document(recipe.id).updateData(data)
        } catch {
            print("Error updating recipe:", error.localizedDescription)
        }
    }

    func deleteRecipe(_ recipe: Recipe) {
        db.collection("recipes").document(recipe.id).delete { error in
            if let error = error {
                print("Error deleting recipe:", error.localizedDescription)
            }
        }
    }

    func toggleSave(_ recipe: Recipe, userID: String) {
        var newSaved = recipe.savedBy

        if let index = newSaved.firstIndex(of: userID) {
            newSaved.remove(at: index)
        } else {
            newSaved.append(userID)
        }

        db.collection("recipes").document(recipe.id).updateData([
            "savedBy": newSaved
        ])
    }

    func vote(recipe: Recipe, upvote: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }

        var updated = recipes[index]

        updated.upvoters.removeAll(where: { $0 == uid })
        updated.downvoters.removeAll(where: { $0 == uid })

        if upvote {
            if !recipe.upvoters.contains(uid) {
                updated.upvoters.append(uid)
            }
        } else {
            if !recipe.downvoters.contains(uid) {
                updated.downvoters.append(uid)
            }
        }

        recipes[index] = updated

        db.collection("recipes").document(recipe.id).updateData([
            "upvoters": updated.upvoters,
            "downvoters": updated.downvoters
        ])
    }
}
