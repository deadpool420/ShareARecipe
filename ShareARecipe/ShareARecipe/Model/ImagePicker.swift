//
//  ImagePicker.swift
//  ShareARecipe
//
//  Created by user286005 on 11/16/25.
//


import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var selectedBase64: String?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.editedImage] as? UIImage
                ?? info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.4) {

                parent.selectedBase64 = data.base64EncodedString()
            }

            picker.dismiss(animated: true)
        }
    }
}
