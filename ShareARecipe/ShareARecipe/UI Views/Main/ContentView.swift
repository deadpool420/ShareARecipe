//
//  ContentView.swift
//  ShareARecipe
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var commentVM: CommentViewModel

    var body: some View {
        Group {
            if authVM.user != nil {
                AuthenticatedRootView()
            } else {
                AuthScreen()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(RecipeViewModel())
        .environmentObject(CommentViewModel())
}
