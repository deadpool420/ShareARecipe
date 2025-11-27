//
//  ShareARecipeApp.swift
//  ShareARecipe
//
//  Created by user286005 on 11/5/25.
//
        	

import SwiftUI
import FirebaseCore

@main
struct ShareARecipeApp: App {

    @StateObject var authVM = AuthViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    @StateObject var commentVM = CommentViewModel()
    @StateObject var groceryVM = GroceryViewModel()
    @StateObject var userSearchVM = UserSearchViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authVM)
                .environmentObject(recipeVM)
                .environmentObject(commentVM)
                .environmentObject(groceryVM)
                .environmentObject(userSearchVM)  
        }
    }
}

		
