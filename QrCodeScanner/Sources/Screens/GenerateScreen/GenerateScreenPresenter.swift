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
    func addCode(withName name: String, date: String, image: Data, imageBarcode: Data?, latitude: Double, longitude: Double)
    func goToMapScreen()
    
    init(view: GenerateScreenViewProtocol, router: RouterProtocol)
}

final class GenerateScreenPresenter: GenerateScreenPresenterProtocol {
    weak var view: GenerateScreenViewProtocol?
    var router: RouterProtocol?
    var model = ModelData()
    var qrCode: [QrCode]?
    var code: QrCode?
    
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
    

    func addCode(withName name: String, date: String, image: Data, imageBarcode: Data?, latitude: Double, longitude: Double) {
        model.addQrCodes(name: name, date: date, image: image, imageBarcode: imageBarcode, latitude: latitude, longitude: longitude)

        fetchAllQrCodes()
    }
    
    func goToMapScreen() {
        router?.showMapDetailScreen(code: code ?? QrCode())
    }
}
