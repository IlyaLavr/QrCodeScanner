//
//  ScanningCodeDetailPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 23.03.2023.
//

import Foundation

protocol ScanningCodeDetailProtocol {
    func setUpParametersCode()
    
    init(code: QrCode, view: ScanningQrCodeDetailScreenProtocol, router: RouterProtocol)
}

final class ScanningCodeDetailPresenter: ScanningCodeDetailProtocol {
    var code: QrCode?
    weak var view: ScanningQrCodeDetailScreenProtocol?
    var router: RouterProtocol?
    
    init(code: QrCode, view: ScanningQrCodeDetailScreenProtocol, router: RouterProtocol) {
        self.code = code
        self.view = view
        self.router = router
    }
    
    func setUpParametersCode() {
        view?.setupDetailedView(name: code?.name ?? "", date: code?.date, image: nil)
    }
}
