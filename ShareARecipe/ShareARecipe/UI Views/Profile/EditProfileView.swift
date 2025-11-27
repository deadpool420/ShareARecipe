//
//  EditProfileView.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct EditProfileView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var location: String = ""
    @State private var birthday: Date = Date()

    @State private var localProfileImageBase64: String? = nil
    @State private var showImagePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        //Profile Photo
                        Button { showImagePicker = true } label: {
                            ZStack {
                                if let base64 = localProfileImageBase64 ?? authVM.userProfile?.profileImageBase64,
                                   let data = Data(base64Encoded: base64),
                                   let image = UIImage(data: data) {

                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 130, height: 130)
                                        .clipShape(RoundedRectangle(cornerRadius: 28))
                                        .shadow(radius: 6)

                                } else {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color(.systemGray5))
                                        .frame(width: 130, height: 130)
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 26))
                                                    .foregroundColor(.gray)
                                                Text("Add Photo")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        )
                                }

                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "pencil")
                                            .foregroundColor(.white)
                                    )
                                    .offset(x: 52, y: 52)
                            }
                        }
                        .padding(.top, 12)

                        //  Basic Info
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Basic Info")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundColor(.gray)

                            VStack(spacing: 14) {
                                iconField(systemImage: "person.fill",
                                          placeholder: "Full Name",
                                          text: $displayName)

                                iconField(systemImage: "at",
                                          placeholder: "Username (@name)",
                                          text: $username)

                                iconField(systemImage: "mappin.and.ellipse",
                                          placeholder: "Location",
                                          text: $location)

                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.orange)
                                        .frame(width: 22)

                                    DatePicker("Birthday",
                                               selection: $birthday,
                                               displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(14)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(radius: 3)
                        .padding(.horizontal)

                        //Bio
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About You")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundColor(.gray)

                            TextField("Bio", text: $bio, axis: .vertical)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(14)
                                .lineLimit(3...6)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(18)
                        .shadow(radius: 3)
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveProfile() }
                        .font(.headline)
                }
            }
            .onAppear { loadData() }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedBase64: $localProfileImageBase64)
            }
        }
    }

    private func iconField(systemImage: String,
                           placeholder: String,
                           text: Binding<String>) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundColor(.orange)
                .frame(width: 22)

            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .autocorrectionDisabled(true)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }

    private func loadData() {
        guard let profile = authVM.userProfile else { return }

        displayName = profile.displayName
        username = profile.username ?? ""
        bio = profile.bio ?? ""
        location = profile.location ?? ""
        localProfileImageBase64 = profile.profileImageBase64

        if let b = profile.birthday {
            let f = DateFormatter()
            f.dateFormat = "dd/MM/yyyy"
            if let parsed = f.date(from: b) { birthday = parsed }
        }
    }

    private func saveProfile() {
        let imgBase64 = localProfileImageBase64 ?? authVM.userProfile?.profileImageBase64

        Task {
            await authVM.updateProfile(
                displayName: displayName,
                username: username.isEmpty ? nil : username,
                profileImageBase64: imgBase64,
                bio: bio.isEmpty ? nil : bio,
                birthday: format(birthday),
                location: location.isEmpty ? nil : location
            )
            dismiss()
        }
    }

    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }
}
