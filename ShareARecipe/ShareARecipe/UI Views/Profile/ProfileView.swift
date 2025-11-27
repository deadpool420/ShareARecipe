//
//  ProfileView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var commentVM: CommentViewModel

    @State private var selectedTab = 0
    @State private var showEditProfile = false
    @State private var selectedRecipe: Recipe? = nil
    @State private var showLogoutAlert = false

    @State private var layoutMode: LayoutMode = .grid
    @State private var openCommentsFor: Recipe? = nil

    enum LayoutMode: String, CaseIterable, Identifiable {
        case grid
        case list
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {

                VStack(spacing: 24) {
                    profileHeader
                    tabSelector
                    postsSection
                }
                .padding(.top, 12)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)

            // Toolbar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {

                    HStack(spacing: 16) {

                        
                        Button {
                            showEditProfile = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }

                        // Logout Button
                        Button {
                            showLogoutAlert = true
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }

            // Logout Alert
            .alert("Log out?", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Logout", role: .destructive) { authVM.signOut() }
            }

            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authVM)
            }

            .sheet(item: $selectedRecipe) { recipe in
                EditRecipeView(recipe: recipe)
                    .environmentObject(recipeVM)
            }

            .sheet(item: $openCommentsFor) { recipe in
                CommentSheetView(recipe: recipe)
                    .environmentObject(authVM)
                    .environmentObject(commentVM)
            }

            .onAppear {
                Task { await authVM.fetchUserProfile() }
            }
        }
    }
}

// PROFILE HEADER
private extension ProfileView {

    var profileHeader: some View {
        HStack(alignment: .top, spacing: 20) {

            // Profile image
            Button { showEditProfile = true } label: {
                if let base64 = authVM.userProfile?.profileImageBase64,
                   let data = Data(base64Encoded: base64),
                   let img = UIImage(data: data) {

                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 130, height: 130)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 130, height: 130)
                        .overlay(Text("Tap to Add").foregroundColor(.gray))
                }
            }

            VStack(alignment: .leading, spacing: 8) {

                // NAME
                if let name = authVM.userProfile?.displayName, !name.isEmpty {
                    Text("Name: \(name)")
                        .font(.subheadline)
                }

                // USERNAME
                if let username = authVM.userProfile?.username, !username.isEmpty {
                    Text("Username: @\(username)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // BIO
                if let bio = authVM.userProfile?.bio, !bio.isEmpty {
                    Text("Bio: \(bio)")
                        .font(.subheadline)
                }

                // LOCATION
                if let location = authVM.userProfile?.location {
                    Text("Location: \(location)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // BIRTHDAY
                if let birthday = authVM.userProfile?.birthday {
                    Text("Birthday: \(birthday)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                // FOLLOWERS/ FOLLOWING
                HStack(spacing: 50) {

                    NavigationLink(
                        destination: FollowersListView(
                            userIDs: authVM.userProfile?.followers ?? []
                        )
                    ) {
                        VStack {
                            Text("Followers")
                                .font(.headline)
                            Text("\(authVM.userProfile?.followers.count ?? 0)")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }

                    NavigationLink(
                        destination: FollowingListView(
                            userIDs: authVM.userProfile?.following ?? []
                        )
                    ) {
                        VStack {
                            Text("Following")
                                .font(.headline)
                            Text("\(authVM.userProfile?.following.count ?? 0)")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.top, 6)
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    // TABS
    var tabSelector: some View {
        HStack(spacing: 0) {
            tabButton("Posts", 0)
            tabButton("Saved", 1)
        }
        .padding(.horizontal)
    }

    func tabButton(_ title: String, _ index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 6) {
                Text(title)
                    .foregroundColor(selectedTab == index ? .black : .gray)

                Rectangle()
                    .fill(selectedTab == index ? Color.orange : .clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // POSTS SECTION
    var postsSection: some View {
        let uid = authVM.user?.uid ?? ""

        let posts = selectedTab == 0
            ? recipeVM.recipes.filter { $0.authorID == uid }
            : recipeVM.recipes.filter { $0.savedBy.contains(uid) }

        return VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("\(posts.count) posts")
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

            if posts.isEmpty {
                Text("No posts yet")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            } else {
                if layoutMode == .grid {
                    gridLayout(posts)
                } else {
                    listLayout(posts)
                }
            }
        }
    }

    // GRID LAYOUT
    private func gridLayout(_ posts: [Recipe]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(posts) { recipe in

                VStack(spacing: 10) {

                    NavigationLink(
                        destination: RecipeDetailView(recipe: recipe)
                    ) {
                        GridThumbnail(recipe: recipe)
                    }

                    engagementRow(for: recipe)

                    Button("Comments") {
                        openCommentsFor = recipe
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal)
    }

    // LIST LAYOUT
    private func listLayout(_ posts: [Recipe]) -> some View {
        LazyVStack(spacing: 18) {

            ForEach(posts) { recipe in

                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    HStack(spacing: 14) {

                        GridThumbnail(recipe: recipe)
                            .frame(width: 90, height: 90)

                        VStack(alignment: .leading, spacing: 8) {

                            Text(recipe.title).font(.headline)
                            Text(recipe.category)
                                .font(.caption)
                                .foregroundColor(.orange)

                            engagementRow(for: recipe)

                            Button("Comments") {
                                openCommentsFor = recipe
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 20)
    }

    private func engagementRow(for recipe: Recipe) -> some View {
        HStack(spacing: 40) {

            VStack(spacing: 2) {
                Text("Upvotes")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(recipe.upvoters.count)")
                    .font(.caption)
            }

            VStack(spacing: 2) {
                Text("Downvotes")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(recipe.downvoters.count)")
                    .font(.caption)
            }

            VStack(spacing: 2) {
                Text("Comments")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("\(recipe.commentCount ?? 0)")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct GridThumbnail: View {
    let recipe: Recipe

    var body: some View {
        if let base64 = recipe.base64Image,
           let data = Data(base64Encoded: base64),
           let uiImg = UIImage(data: data) {

            Image(uiImage: uiImg)
                .resizable()
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width/2 - 24,
                    height: UIScreen.main.bounds.width/2 - 24
                )
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))

        } else {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.gray.opacity(0.25))
                .frame(
                    width: UIScreen.main.bounds.width/2 - 24,
                    height: UIScreen.main.bounds.width/2 - 24
                )
        }
    }
}
