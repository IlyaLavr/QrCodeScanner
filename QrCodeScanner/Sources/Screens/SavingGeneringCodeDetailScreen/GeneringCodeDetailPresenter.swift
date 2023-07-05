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
    func errorSaveGallery()
    func deleteCode(index: IndexPath)
    func shareQr()
    func goToMap()
}

final class GeneringCodeDetailPresenter: GeneringCodeDetailProtocol {
    var code: QrCode?
    weak var view: SavingGeneringCodeViewProtocol?
    var router: RouterProtocol?
    var model = ModelData()
    var qrCode: [QrCode]?
    
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
            let alert = Alert.errorSaveGallery
            self.view?.showAlert(with: alert)
        })
    }
    
    func showAlertSuccefulSave() {
        let alert = Alert.succefulSaveInGalery
        view?.showAlert(with: alert)
    }
    
    func errorSaveGallery() {
        let alert = Alert.errorSaveGallery
        view?.showAlert(with: alert)
    }
    
    func shareQr() {
        view?.shareImageQrCode()
    }
    
    func goToMap() {
        router?.showMapDetailScreen(code: code ?? QrCode())
    }
    
    func fetchAllQrCodes() {
        qrCode = model.getAllQrCodes().reversed()
    }
    
    func deleteCode(index: IndexPath) {
        model.deleteCode(code: code ?? QrCode())
        router?.popToRoot()
        fetchAllQrCodes()
    }
}
