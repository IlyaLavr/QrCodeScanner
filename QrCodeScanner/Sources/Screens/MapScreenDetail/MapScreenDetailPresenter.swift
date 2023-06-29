//
//  MapScreenDetailPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 11.04.2023.
//

import Foundation

protocol MapScreenDetailProtocol: AnyObject {
    func setupCoordinatesView()
}

final class MapScreenDetailPresenter: MapScreenDetailProtocol {
    weak var view: MapDetailScreenProtocol?
    var router: RouterProtocol?
    var model = ModelData()
    var qrCode: QrCode?
    
    init(code: QrCode, view: MapDetailScreenProtocol, router: RouterProtocol) {
        self.qrCode = code
        self.view = view
        self.router = router
    }
    
    func setupCoordinatesView() {
        guard let latitude = qrCode?.latitude, let longitude = qrCode?.longitude, let name = qrCode?.name else {
                return
            }
        view?.setupCodeOnMap(latitude: latitude, longitude: longitude, name: name)
    }
}
