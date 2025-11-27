//
//  UserProfile.swift
//  ShareARecipe
//
//  Created by user286005 on 11/10/25.
//


import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String { uid }

    let uid: String
    var displayName: String
    var username: String?
    var email: String
    var profileImageBase64: String?

    var birthday: String?
    var bio: String?
    var location: String?

    var followers: [String]
    var following: [String]      

    let createdAt: Date
}
