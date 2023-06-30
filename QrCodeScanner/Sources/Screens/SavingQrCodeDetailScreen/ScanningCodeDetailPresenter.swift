//
//  ScanningCodeDetailPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 23.03.2023.
//

import Foundation

protocol ScanningCodeDetailProtocol {
    func setUpParametersCode()
    func goToMap()
    func openLink(url: String)
    func searchInBrowser(url: String)
    func deleteCode(index: IndexPath)
}

final class ScanningCodeDetailPresenter: ScanningCodeDetailProtocol {
    var code: QrCode?
    weak var view: ScanningQrCodeDetailScreenProtocol?
    var router: RouterProtocol?
    var model = ModelData()
    var qrCode: [QrCode]?
    
    init(code: QrCode, view: ScanningQrCodeDetailScreenProtocol, router: RouterProtocol) {
        self.code = code
        self.view = view
        self.router = router
    }
    
    func setUpParametersCode() {
        view?.setupDetailedView(name: code?.name ?? "", date: code?.date, image: code?.imageBarcode)
    }
    
    func goToMap() {
        router?.showMapDetailScreen(code: code ?? QrCode())
    }
    
    func openLink(url: String) {
        Network.shared.openLinkInBrowser(url)
    }
    
    func searchInBrowser(url: String) {
        Network.shared.searchProductByCode(url)
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
