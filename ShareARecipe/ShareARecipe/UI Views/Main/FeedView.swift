//
//  FeedView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//
import SwiftUI

struct FeedView: View {

    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var commentVM: CommentViewModel

    @State private var searchText = ""

    var filteredRecipes: [Recipe] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return recipeVM.recipes
        }
        return recipeVM.recipes.filter {
            $0.title.lowercased().contains(searchText.lowercased()) ||
            $0.ingredients.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(filteredRecipes) { recipe in
                        NavigationLink {
                            FullScreenRecipeView(recipe: recipe)
                                .environmentObject(authVM)
                                .environmentObject(recipeVM)
                                .environmentObject(commentVM)
                        } label: {
                            RecipeCardView(recipe: recipe)
                                .environmentObject(authVM)
                                .environmentObject(recipeVM)
                                .environmentObject(commentVM)
                                .transition(.opacity.combined(with: .scale))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .navigationTitle("ShareARecipe")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .animation(.smooth, value: searchText)
            .onAppear {
                recipeVM.fetchRecipes()
            }
        }
    }
}

