//
//  Strings.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import Foundation

enum Strings {
    enum MainScreen {
        static let animation = "main"
        static let textButton = "Scan"
    }
    
    enum ScanAnimationScreen {
        static let animationName = "qr-scannig-process"
        static let labelDetectedText = "Наведите камеру на код"
        static let shareButtonText = "Поделиться"
    }
    
    enum GenerateScreen {
        static let background = "background"
        
        static let textFieldLinkPlaceholder = "Введите текст или URL"
        
        static let buttonGenerate = "button"
        static let buttonSave = "camera.circle"
        static let buttonShare = "square.and.arrow.up.circle"
    }
}
