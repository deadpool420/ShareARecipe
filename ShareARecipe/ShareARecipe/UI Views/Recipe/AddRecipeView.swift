//
//  AddRecipeView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.


import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

struct AddRecipeView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var title: String = ""
    @State private var ingredients: String = ""
    @State private var steps: String = ""
    @State private var category: String = "Breakfast"
    @State private var base64Image: String? = nil
    @State private var showImagePicker = false
    @State private var showSuccess = false
    @State private var isSaving = false

    private let categories = [
        "Breakfast", "Lunch", "Dinner", "Snacks",
        "Dessert", "Beverage", "Vegan", "Indian",
        "Italian", "Mexican", "Other"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

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
                                            Image(systemName: "photo.on.rectangle")
                                                .font(.system(size: 32))
                                            Text("Tap to add photo")
                                                .foregroundColor(.gray)
                                        }
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title").font(.headline)
                        TextField("e.g. Paneer Butter Masala", text: $title)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Ingredients").font(.headline)

                        TextEditor(text: $ingredients)
                            .frame(minHeight: 120)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Steps").font(.headline)

                        TextEditor(text: $steps)
                            .frame(minHeight: 160)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Recipe")

            .toolbar {

                ToolbarItem(placement: .keyboard) {
                    Button("Done") {
                        UIApplication.shared.endEditing()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSaving ? "Saving..." : "Save") {
                        Task { await saveRecipe() }
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaving ||
                              title.trimmingCharacters(in: .whitespaces).isEmpty ||
                              ingredients.trimmingCharacters(in: .whitespaces).isEmpty ||
                              steps.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedBase64: $base64Image)
            }

            .alert("Recipe Added Successfully!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func resetForm() {
        title = ""
        ingredients = ""
        steps = ""
        category = "Breakfast"
        base64Image = nil
    }

    private func saveRecipe() async {
        guard let uid = authVM.user?.uid else { return }

        isSaving = true

        let recipe = Recipe(
            id: UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            ingredients: ingredients.trimmingCharacters(in: .whitespacesAndNewlines),
            steps: steps.trimmingCharacters(in: .whitespacesAndNewlines),
            base64Image: base64Image,
            createdAt: Date(),
            authorID: uid,
            authorName: authVM.userProfile?.displayName ?? "Unknown",
            authorImageBase64: authVM.userProfile?.profileImageBase64,
            savedBy: [],
            upvoters: [],
            downvoters: [],
            category: category
        )

        await recipeVM.addRecipe(recipe)

        isSaving = false
        resetForm()
        showSuccess = true
    }
}
