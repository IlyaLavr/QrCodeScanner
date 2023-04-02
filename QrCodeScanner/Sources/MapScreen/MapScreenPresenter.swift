//
//  MapScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 03.04.2023.
//

import Foundation

protocol MapScreenPresenterProtocol: AnyObject {

}

final class MapScreenPresenter: MapScreenPresenterProtocol {
    weak var view: MapScreenViewProtocol?
    var router: RouterProtocol?
    
    init(view: MapScreenViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
}
