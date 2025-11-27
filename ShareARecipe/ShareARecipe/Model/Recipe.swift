//
//  Recipe.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import Foundation

struct Recipe: Identifiable, Codable, Hashable {

    var id: String
    var title: String
    var ingredients: String
    var steps: String
    var base64Image: String?

    var createdAt: Date

    var authorID: String
    var authorName: String
    var authorImageBase64: String?

    var savedBy: [String]

    // Voting system
    var upvoters: [String]
    var downvoters: [String]

    // Category
    var category: String

    // Comment count stored separately
    var commentCount: Int?

    // Computed Reddit-style score
    var score: Int {
        upvoters.count - downvoters.count
    }
}
