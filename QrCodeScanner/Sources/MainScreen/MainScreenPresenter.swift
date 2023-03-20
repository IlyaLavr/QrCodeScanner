//
//  MainScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import Foundation

protocol MainPresenterProtocol: AnyObject {
    func goToScanVc()
    init(view: MainViewProtocol, router: RouterProtocol)
}

final class MainScreenPresenter: MainPresenterProtocol {
    weak var view: MainViewProtocol?
    var router: RouterProtocol?
    
    required init(view: MainViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func goToScanVc() {
        router?.showQrScanner()
    }
}
