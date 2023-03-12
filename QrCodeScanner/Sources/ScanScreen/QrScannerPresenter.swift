//
//  QrScannerPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import UIKit
import WebKit

protocol QrScannerPresenterProtocol: AnyObject {
    func saveAsPDF(from webView: WKWebView?)
}

class QrScannerPresenter: QrScannerPresenterProtocol, PDFGeneratorPresenterProtocol {
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
            activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                if completed {
                    self.view?.showAlert(title: "PDF Saved", message: "Файл был успешно сохранен")
                } else {
                    self.view?.showAlert(title: "Failed to save PDF.", message: "Не удалось сохранить файл")
                }
            }
            self.viewController?.present(activityViewController, animated: true, completion: nil)
        } else {
            self.view?.showAlert(title: "Error", message: "Failed to save PDF.")
        }
    }
}
