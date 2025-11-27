//
//  AuthenticatedRootView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/17/25.


import SwiftUI

struct AuthenticatedRootView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var commentVM: CommentViewModel
    @EnvironmentObject var groceryVM: GroceryViewModel

    var body: some View {
        TabView {

            FeedView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            AddRecipeView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            GroceryListView()                    
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    AuthenticatedRootView()
        .environmentObject(AuthViewModel())
        .environmentObject(RecipeViewModel())
        .environmentObject(CommentViewModel())
        .environmentObject(GroceryViewModel())
}
