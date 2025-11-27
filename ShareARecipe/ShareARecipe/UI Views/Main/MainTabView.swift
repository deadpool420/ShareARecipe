//
//  MainTabView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var commentVM: CommentViewModel

    var body: some View {
        TabView {

            NavigationStack {
                FeedView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                SavedView()
            }
            .tabItem {
                Label("Saved", systemImage: "bookmark.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(RecipeViewModel())
        .environmentObject(CommentViewModel())
}
