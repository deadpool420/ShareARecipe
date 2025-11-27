//
//  RecipeComment.swift
//  ShareARecipe
//
//  Created by user286005 on 11/22/25.

import Foundation

struct RecipeComment: Identifiable, Codable, Hashable {
    var id: String
    var userID: String
    var userName: String
    var text: String
    var createdAt: Date
    var userImageBase64: String?

    init(
        id: String = UUID().uuidString,
        userID: String,
        userName: String,
        text: String,
        createdAt: Date = Date(),
        userImageBase64: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.userName = userName
        self.text = text
        self.createdAt = createdAt
        self.userImageBase64 = userImageBase64
    }
}


