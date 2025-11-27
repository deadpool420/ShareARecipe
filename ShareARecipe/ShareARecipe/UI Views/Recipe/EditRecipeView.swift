//
//  EditRecipeView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct EditRecipeView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeVM: RecipeViewModel

    let recipe: Recipe

    @State private var title: String = ""
    @State private var ingredients: String = ""
    @State private var steps: String = ""
    @State private var category: String = ""
    @State private var base64Image: String? = nil
    @State private var showImagePicker = false

    private let categories = [
        "Breakfast", "Lunch", "Dinner", "Snacks",
        "Dessert", "Beverage", "Vegan", "Indian",
        "Italian", "Mexican", "Other"
    ]

    init(recipe: Recipe) {
        self.recipe = recipe
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    // IMAGE PICKER
                    Button {
                        showImagePicker = true
                    } label: {
                        ZStack {
                            if let base64 = base64Image,
                               let data = Data(base64Encoded: base64),
                               let img = UIImage(data: data) {

                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 220)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 18))

                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.systemGray6))
                                    .frame(height: 220)
                                    .overlay(
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo")
                                                .font(.system(size: 32))
                                            Text("Tap to change photo")
                                                .foregroundColor(.gray)
                                        }
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    // TITLE
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title").font(.headline)
                        TextField("Title", text: $title)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    // CATEGORY
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category").font(.headline)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { cat in
                                    Text(cat)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(category == cat ? Color.orange : Color(.systemGray5))
                                        .foregroundColor(category == cat ? .white : .black)
                                        .cornerRadius(12)
                                        .onTapGesture { category = cat }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // INGREDIENTS
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ingredients").font(.headline)
                        TextEditor(text: $ingredients)
                            .frame(minHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    // STEPS
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Steps").font(.headline)
                        TextEditor(text: $steps)
                            .frame(minHeight: 140)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Edit Recipe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty ||
                              ingredients.trimmingCharacters(in: .whitespaces).isEmpty ||
                              steps.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedBase64: $base64Image)
            }
            .onAppear {
                if title.isEmpty {
                    title       = recipe.title
                    ingredients = recipe.ingredients
                    steps       = recipe.steps
                    base64Image = recipe.base64Image
                    category    = recipe.category
                }
            }
        }
    }

    private func saveChanges() {

        let updated = Recipe(
            id: recipe.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            steps: steps.trimmingCharacters(in: .whitespacesAndNewlines),
            base64Image: base64Image,
            createdAt: recipe.createdAt,
            authorID: recipe.authorID,
            authorName: recipe.authorName,
            authorImageBase64: recipe.authorImageBase64,
            savedBy: recipe.savedBy,
            upvoters: recipe.upvoters,       
            downvoters: recipe.downvoters,
            category: category
        )

        Task {
            await recipeVM.updateRecipe(recipe: updated)
            dismiss()
        }
    }
}
