//
//  QrScannerPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit
import WebKit

protocol QrScannerPresenterProtocol: AnyObject {
   
}

class QrScannerPresenter: QrScannerPresenterProtocol {
    weak var view: QRScannerControllerProtocol?
    var router: RouterProtocol?

    required init(view: QRScannerControllerProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
}
