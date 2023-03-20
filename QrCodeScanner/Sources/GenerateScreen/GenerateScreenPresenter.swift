//
//  GenerateScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 20.03.2023.
//

import Foundation

protocol GenerateScreenPresenterProtocol: AnyObject {
    init(view: GenerateScreenViewProtocol, router: RouterProtocol)
}

final class GenerateScreenPresenter: GenerateScreenPresenterProtocol {
    weak var view: GenerateScreenViewProtocol?
    var router: RouterProtocol?
    
    init(view: GenerateScreenViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
}
