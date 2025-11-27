//
//  GroceryModels.swift
//  ShareARecipe
//
//  Created by user286005 on 11/22/25.
//


import Foundation

struct GroceryItem: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String = ""
    var isChecked: Bool = false
    var category: String = "Other"
}

struct GroceryList: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var userID: String = ""
    var title: String = ""
    var items: [GroceryItem] = []
    var createdAt: Date = Date()
}

