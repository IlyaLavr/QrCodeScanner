//
//  ExtensionUIImage.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
