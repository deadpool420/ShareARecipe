//
//  SearchView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct SearchView: View {

    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var userSearchVM: UserSearchViewModel 

    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var recentSearches: [String] =
        UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []

    enum LayoutMode: String, CaseIterable, Identifiable {
        case grid
        case list
        var id: String { rawValue }
    }

    @State private var layoutMode: LayoutMode = .grid

    let categories = [
        "All", "Breakfast", "Lunch", "Dinner", "Snacks",
        "Dessert", "Beverage", "Vegan", "Indian",
        "Italian", "Mexican", "Other"
    ]

    // FILTER USERS
    private var filteredUsers: [UserProfile] {
        let text = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return [] }

        return userSearchVM.allUsers.filter { user in
            let display = user.displayName.lowercased()
            let uname = user.username?.lowercased() ?? ""
            return display.contains(text) || uname.contains(text)
        }
    }

    // FILTER RECIPES
    private var filteredRecipes: [Recipe] {

        let byCategory = recipeVM.recipes.filter { r in
            if selectedCategory == "All" { return true }
            return r.category.lowercased() == selectedCategory.lowercased()
        }

        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return byCategory.sorted { $0.createdAt > $1.createdAt }
        }

        return byCategory.filter { recipe in
            recipe.title.lowercased().contains(trimmed.lowercased()) ||
            recipe.ingredients.lowercased().contains(trimmed.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 16) {

                    // SEARCH BAR (kept your design)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search recipes or users...",
                                  text: $searchText,
                                  onCommit: addRecentSearch)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .animation(.smooth, value: searchText)

                    // CATEGORY FILTER
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { cat in
                                Text(cat)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.orange : Color(.systemGray5))
                                    .foregroundColor(selectedCategory == cat ? .white : .black)
                                    .clipShape(Capsule())
                                    .onTapGesture { selectedCategory = cat }
                                    .animation(.bouncy, value: selectedCategory)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // RECENT SEARCHES
                    if !recentSearches.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {

                            Text("Recent")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recentSearches, id: \.self) { term in
                                        Text(term)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.15))
                                            .clipShape(Capsule())
                                            .onTapGesture { searchText = term }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // USER RESULTS
                    if !filteredUsers.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {

                            Text("Users")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(filteredUsers, id: \.uid) { user in
                                NavigationLink(destination: PublicProfileView(userID: user.uid)) {

                                    HStack(spacing: 12) {

                                        // PROFILE IMG
                                        if let base64 = user.profileImageBase64,
                                           let data = Data(base64Encoded: base64),
                                           let img = UIImage(data: data) {

                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())

                                        } else {
                                            Circle()
                                                .fill(Color.gray.opacity(0.4))
                                                .frame(width: 40, height: 40)
                                                .overlay(Image(systemName: "person.fill"))
                                        }

                                        VStack(alignment: .leading) {
                                            Text(user.displayName)
                                                .font(.headline)

                                            Text("@\(user.username ?? "")")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 6)
                                }
                            }
                        }
                    }

                    let results = filteredRecipes

                    HStack {
                        Text(results.isEmpty
                             ? "No recipes found"
                             : "\(results.count) recipe\(results.count > 1 ? "s" : "")")
                            .foregroundColor(.gray)

                        Spacer()

                        Picker("Layout", selection: $layoutMode) {
                            Text("Grid").tag(LayoutMode.grid)
                            Text("List").tag(LayoutMode.list)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    .padding(.horizontal)

                    // MAIN RESULTS
                    if results.isEmpty {
                        emptyState
                    } else {
                        resultsView(results)
                    }

                }
                .padding(.top, 8)
            }
            .navigationTitle("Search")
            .onAppear {
                recipeVM.fetchRecipes()
                userSearchVM.fetchAllUsers()
            }
        }
    }

    // EMPTY STATE
    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Nothing found.")
                .foregroundColor(.gray)
            Text("Try different keywords or categories.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // GRID /LIST SWITCH
    @ViewBuilder
    private func resultsView(_ recipes: [Recipe]) -> some View {
        switch layoutMode {
        case .grid:
            gridResults(recipes)
        case .list:
            listResults(recipes)
        }
    }

    // GRID VIEW
    @ViewBuilder
    private func gridResults(_ recipes: [Recipe]) -> some View {

        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]

        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    recipeThumbnail(recipe)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .padding(.horizontal)
    }

    // LIST VEW
    @ViewBuilder
    private func listResults(_ recipes: [Recipe]) -> some View {

        LazyVStack(spacing: 12) {
            ForEach(recipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack(spacing: 12) {

                        recipeThumbnail(recipe)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.title).font(.headline)
                            Text(recipe.ingredients)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    // THUMBNAIL
    private func recipeThumbnail(_ recipe: Recipe) -> some View {
        let size = UIScreen.main.bounds.width / 2 - 20

        if let base64 = recipe.base64Image,
           let data = Data(base64Encoded: base64),
           let img = UIImage(data: data) {

            return AnyView(
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }

        return AnyView(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
        )
    }

    // SAVE RECENT
    private func addRecentSearch() {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if !recentSearches.contains(trimmed) {
            recentSearches.insert(trimmed, at: 0)
            if recentSearches.count > 8 {
                recentSearches.removeLast()
            }
            UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
        }
    }
}
