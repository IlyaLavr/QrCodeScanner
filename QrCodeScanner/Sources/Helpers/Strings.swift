//
//  Strings.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import Foundation

enum Strings {
    enum MainScreen {
        static let background = "background"
        static let animation = "main"
        static let button = "buttonscan"
    }
    
    enum ScanAnimationScreen {
        static let animationName = "qr-scannig-process"
        static let labelDetectedText = "Наведите камеру на код"
        static let shareButtonText = "Поделиться"
        
        static let flashButtonOn = "bolt.circle.fill"
        static let flashButtonOff = "bolt.circle"
        static let thumbImage = "zoom"
        
        static let toolBarRigthButton = "square.and.arrow.up"
        
        static let imageForBarcode = "barcode"
        
        static let closeButtonNewWindow = "xmark"
        static let titleCopyNewWindow = "Копировать"
        static let titleOpenLinkNewWindow = "Открыть"
    }
    
    enum GenerateScreen {
        static let background = "background"
        static let textFieldLinkPlaceholder = "Введите текст или URL"
        
        static let buttonGenerate = "buttongenerate"
        static let buttonSave = "camera.circle"
        static let buttonShare = "square.and.arrow.up.circle"
    }
    
    enum TabBar {
        static let firstTitle = "Scan"
        static let firstImage = "qrcode.viewfinder"
        
        static let secondTitle = "Generate"
        static let secondImage = "circle.hexagonpath"
        
        static let thirdTitle = "History"
        static let thirdImage = "magazine"
    }
    
    enum DetailScreenScanCode {
        static let buttonOpenLink = "openlink"
        static let search = "search"
        static let viewOnMap = "mappin.and.ellipse"
    }
    
    enum MapScreen {
        static let currentLocationImage = "location.circle.fill"
    }
    
    enum HistoryScreen {
        static let titleButtonMap = "Посмотреть на карте"
    }
}
