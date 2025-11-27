//
//  RecipeListView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct RecipeListView: View {
    @EnvironmentObject var recipeVM: RecipeViewModel

    var body: some View {
        NavigationStack {
            List(recipeVM.recipes) { recipe in
                VStack(alignment: .leading, spacing: 6) {
                    Text(recipe.title)
                        .font(.headline)

                    Text(recipe.ingredients)
                        .font(.subheadline)
                        .lineLimit(1)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Recipes")
            .onAppear { recipeVM.fetchRecipes() }
        }
    }
}

#Preview {
    RecipeListView()
        .environmentObject(RecipeViewModel())
}
