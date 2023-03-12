//
//  QrScannerViewController.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit

protocol QRScannerControllerProtocol: AnyObject {
   
}

class QrScannerViewController: UIViewController, QRScannerControllerProtocol {
    var presenter: QrScannerPresenterProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
}
