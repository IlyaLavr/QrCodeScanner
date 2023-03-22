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
    
    init(view: GenerateScreenViewProtocol, router: RouterProtocol)
}

final class GenerateScreenPresenter: GenerateScreenPresenterProtocol {
    weak var view: GenerateScreenViewProtocol?
    var router: RouterProtocol?
    
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
}
