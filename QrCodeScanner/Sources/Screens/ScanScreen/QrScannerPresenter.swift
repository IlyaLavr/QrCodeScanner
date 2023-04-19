//
//  QrScannerPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import Foundation

protocol PDFGeneratorPresenterProtocol: AnyObject {
    var router: RouterProtocol? { get }
    var view: PDFGeneratorViewProtocol? { get }
    
    func saveAsPDF(data: NSData)
    func showAlertNoInternet()
    func showAlertCopyUrl()
    func openLinkBarCode(barcode: String)
    func addCode(withName name: String, date: String, image: Data?, imageBarcode: Data?, latitude: Double, longitude: Double)
}

final class QrScannerPresenter: PDFGeneratorPresenterProtocol {
    var router: RouterProtocol?
    weak var view: PDFGeneratorViewProtocol?
    var model = ModelData()
    var qrCode: [QrCode]?
    
    required init(router: RouterProtocol, view: PDFGeneratorViewProtocol) {
        self.router = router
        self.view = view
    }
    
    func saveAsPDF(data: NSData) {
        view?.saveFile(data: data)
    }
    
    func showAlertNoInternet() {
        let alert = Alert.noInternet
        self.view?.displayAlertStatusSave(with: alert)
    }
    
    func showAlertCopyUrl() {
        let alert = Alert.urlCopy
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
            self.view?.scanAnimation.play()
        },
                           cancelHandler: { cancelAction in
            self.view?.qrCodeFrameView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            self.view?.startScan()
            self.view?.labelDetected.text = Strings.ScanAnimationScreen.labelDetectedText
            self.view?.scanAnimation.play()
        })
    }
    
    func fetchAllQrCodes() {
        qrCode = model.getAllQrCodes().reversed()
    }
    func addCode(withName name: String, date: String, image: Data?, imageBarcode: Data?, latitude: Double, longitude: Double) {
        model.addQrCodes(name: name, date: date, image: nil, imageBarcode: imageBarcode, latitude: latitude, longitude: longitude)
        fetchAllQrCodes()
    }
}
