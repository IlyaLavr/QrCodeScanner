//
//  QrScannerPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit
import WebKit

protocol PDFGeneratorPresenterProtocol: AnyObject {
    func saveAsPDF(from webView: WKWebView?)
    func showAlertNoInternet()
    func openLinkBarCode(barcode: String)
}

class QrScannerPresenter: PDFGeneratorPresenterProtocol {
    var router: RouterProtocol?
    var model: ModelProtocol?
    weak var view: PDFGeneratorViewProtocol?
    var viewController: UIViewController? {
        return view as? UIViewController
    }
    
    required init(router: RouterProtocol, model: ModelProtocol, view: PDFGeneratorViewProtocol) {
        self.router = router
        self.model = model
        self.view = view
    }
    
    func saveAsPDF(from webView: WKWebView?) {
        let pdfData = model?.exportAsPDF(from: webView)
        if pdfData != nil {
            let activityViewController = UIActivityViewController(activityItems: [pdfData as Any], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { (_, completed, _, error) in
                if completed {
                    let alert = Alert.succefulSave
                    self.view?.displayAlertStatusSave(with: alert)
                } else {
                    let alert = Alert.failedSave
                    self.view?.displayAlertStatusSave(with: alert)
                }
            }
            self.viewController?.present(activityViewController, animated: true, completion: nil)
        } else {
            let alert = Alert.failedSave
            self.view?.displayAlertStatusSave(with: alert)
        }
    }
    
    func showAlertNoInternet() {
        let alert = Alert.noInternet
        self.view?.displayAlertStatusSave(with: alert)
    }
    
    func openLinkBarCode(barcode: String) {
        let alertType = Alert.openBrowser
        view?.displayAlert(with: alertType,
                           okHandler: { action in
            Network.shared.searchProductByCode(barcode)
            self.view?.qrCodeFrameView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.view?.startScan()
            self.view?.labelDetected.text = Strings.ScanAnimationScreen.labelDetectedText
        },
                           cancelHandler: { cancelAction in
            self.view?.qrCodeFrameView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.view?.startScan()
            self.view?.labelDetected.text = Strings.ScanAnimationScreen.labelDetectedText
        })
    }
}
