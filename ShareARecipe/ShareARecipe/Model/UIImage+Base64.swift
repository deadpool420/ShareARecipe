//
//  UIImage+Base64.swift
//  ShareARecipe
//
//  Created by user286005 on 11/17/25.
//

import UIKit

extension UIImage {
    func toBase64() -> String? {
        self.jpegData(compressionQuality: 0.4)?.base64EncodedString()
    }

    static func fromBase64(_ base64: String?) -> UIImage? {
        guard let base64 = base64,
              let data = Data(base64Encoded: base64) else { return nil }
        return UIImage(data: data)
    }
}
