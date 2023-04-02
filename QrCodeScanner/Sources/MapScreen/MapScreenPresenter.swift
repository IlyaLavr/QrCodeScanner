//
//  MapScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 03.04.2023.
//

import Foundation

protocol MapScreenPresenterProtocol: AnyObject {
    func fetchAllQrCodes() -> [QrCode]
}

final class MapScreenPresenter: MapScreenPresenterProtocol {
    weak var view: MapScreenViewProtocol?
    var router: RouterProtocol?
    var model = ModelData()
    var qrCode: [QrCode]?
    
    init(view: MapScreenViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func fetchAllQrCodes() -> [QrCode] {
        qrCode = model.getAllQrCodes()
        return qrCode ?? []
    }
}
