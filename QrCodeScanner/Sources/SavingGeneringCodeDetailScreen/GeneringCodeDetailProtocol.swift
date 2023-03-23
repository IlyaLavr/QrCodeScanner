//
//  GeneringCodeDetailProtocol.swift
//  QrCodeScanner
//
//  Created by Илья on 23.03.2023.
//

import Foundation

protocol GeneringCodeDetailProtocol {
    func setUpParametersCode()
    
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
}
