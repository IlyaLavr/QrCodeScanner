//
//  GenerateScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 20.03.2023.
//

import Foundation

protocol GenerateScreenPresenterProtocol: AnyObject {
    func shareQr()
    func showAlertEmptyString()
    func saveInPhone()
    func showAlertSuccefulSave()
    func addCode(withName name: String, date: String, image: Data, imageBarcode: Data?)
    
    init(view: GenerateScreenViewProtocol, router: RouterProtocol)
}

final class GenerateScreenPresenter: GenerateScreenPresenterProtocol {
    weak var view: GenerateScreenViewProtocol?
    var router: RouterProtocol?
    var model = ModelData()
    var qrCode: [QrCode]?
    
    init(view: GenerateScreenViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func shareQr() {
        view?.shareImageQrCode()
    }
    
    func showAlertEmptyString() {
        let alert = Alert.emptyStrig
        view?.showAlert(with: alert)
    }
    
    func showAlertSuccefulSave() {
        let alert = Alert.succefulSaveInGalery
        view?.showAlert(with: alert)
    }
    
    func saveInPhone() {
        let alertType = Alert.saveInGaleryStatus
        view?.showAlertSaveToGalery(with: alertType, okHandler: { action in
            self.view?.saveQr()
        }, cancelHandler: { cancelAction in
            print(cancelAction)
        })
    }
    
    func fetchAllQrCodes() {
        qrCode = model.getAllQrCodes().reversed()
    }
    
    func addCode(withName name: String, date: String, image: Data, imageBarcode: Data?) {
        model.addQrCodes(name: name, date: date, image: image, imageBarcode: imageBarcode)
        fetchAllQrCodes()
    }
}