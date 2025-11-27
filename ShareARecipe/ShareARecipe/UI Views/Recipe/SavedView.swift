//
//  SavedView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct SavedView: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                    ForEach(recipeVM.recipes.filter { $0.savedBy.contains(authVM.user?.uid ?? "") }) { recipe in
                        VStack {
                            if let base64 = recipe.base64Image,
                               let data = Data(base64Encoded: base64),
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .cornerRadius(12)
                                    .clipped()
                            }

                            Text(recipe.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Saved Recipes")
            .onAppear {
                recipeVM.fetchRecipes()
            }
        }
    }
}

#Preview {
    SavedView()
        .environmentObject(RecipeViewModel())
        .environmentObject(AuthViewModel())
}
