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
        view?.showAlertEmptyString(with: alert)
        
    }
}
