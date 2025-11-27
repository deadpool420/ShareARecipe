//
//  RecipeDetailView.swift
//  ShareARecipe
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct RecipeDetailView: View {

    let recipe: Recipe

    @EnvironmentObject var commentVM: CommentViewModel
    @State private var showComments = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {

                if let base64 = recipe.base64Image,
                   let data = Data(base64Encoded: base64),
                   let img = UIImage(data: data) {

                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                }

                Text(recipe.title)
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                Text("Category: \(recipe.category)")
                    .foregroundColor(.gray)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.title2.bold())

                    Text(recipe.ingredients)
                        .font(.body)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps")
                        .font(.title2.bold())

                    Text(recipe.steps)
                        .font(.body)
                }
                .padding(.horizontal)

                Button {
                    showComments = true
                } label: {
                    HStack {
                        Image(systemName: "text.bubble")
                        Text("View Comments")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Recipe")
        .sheet(isPresented: $showComments) {
            CommentSheetView(recipe: recipe)
                .environmentObject(commentVM)
        }
    }
}
