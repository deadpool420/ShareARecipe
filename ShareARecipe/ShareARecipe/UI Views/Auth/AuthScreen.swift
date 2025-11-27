//
//  AuthScreen.swift
//  ShareARecipe
//
//  Created by user286005 on 11/10/25.
//

import SwiftUI

struct AuthScreen: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var isSignUp = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 22) {

            // Title
            Text(isSignUp ? "Create Account" : "Welcome Back")
                .font(.system(size: 32, weight: .bold))
                .padding(.top, 20)

            Text(isSignUp ? "Join the community" : "Login to continue")
                .font(.system(size: 16))
                .foregroundColor(.gray)

            if isSignUp {
                TextField("Full Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .textInputAutocapitalization(.words)
            }

            TextField("Email Address", text: $email)
                .padding()
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.none)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // Password
            SecureField("Password (min 6 chars)", text: $password)
                .padding()
                .textContentType(.password)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.none)
                .background(Color(.systemGray6))
                .cornerRadius(10)

            // LOGIN AND SIGNUP BUTTON
            Button(action: {
                Task {
                    if isSignUp {
                        await authVM.register(
                            email: email,
                            password: password,
                            displayName: name
                        )
                    } else {
                        await authVM.login(
                            email: email,
                            password: password
                        )
                    }
                }
            }) {
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                    .font(.system(size: 18, weight: .semibold))
            }
            .padding(.top, 10)

            Button(isSignUp ? "Already have an account? Sign in" :
                              "Don't have an account? Sign up") {
                isSignUp.toggle()
            }
            .foregroundColor(.blue)
            .font(.system(size: 15))

            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

#Preview {
    AuthScreen().environmentObject(AuthViewModel())
}
