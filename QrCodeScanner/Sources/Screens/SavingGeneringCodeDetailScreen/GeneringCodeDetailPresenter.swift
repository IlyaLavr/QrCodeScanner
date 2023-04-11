//
//  GeneringCodeDetailPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 23.03.2023.
//

import Foundation

protocol GeneringCodeDetailProtocol {
    func setUpParametersCode()
    func saveInPhone()
    func showAlertSuccefulSave()
    func shareQr()
    func goToMap()
    
    init(code: QrCode, view: SavingGeneringCodeViewProtocol, router: RouterProtocol)
}

final class GeneringCodeDetailPresenter: GeneringCodeDetailProtocol {
    var code: QrCode?
    weak var view: SavingGeneringCodeViewProtocol?
    var router: RouterProtocol?
    
    init(code: QrCode, view: SavingGeneringCodeViewProtocol, router: RouterProtocol) {
        self.code = code
        self.view = view
        self.router = router
    }
    
    func setUpParametersCode() {
        view?.setupDetailedView(name: code?.name ?? "", date: code?.date, image: code?.image)
    }
    
    func saveInPhone() {
        let alertType = Alert.saveInGaleryStatus
        view?.showAlertSaveToGalery(with: alertType, okHandler: { action in
            self.view?.saveQr()
        }, cancelHandler: { cancelAction in
            print(cancelAction)
        })
    }
    
    func showAlertSuccefulSave() {
        let alert = Alert.succefulSaveInGalery
        view?.showAlert(with: alert)
    }
    
    func shareQr() {
        view?.shareImageQrCode()
    }
    
    func goToMap() {
        router?.showMapDetailScreen(code: code ?? QrCode())
    }
}
