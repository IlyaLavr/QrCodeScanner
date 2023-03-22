//
//  HistoryScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//

import Foundation

protocol HistoryScreenPresenterProtocol: AnyObject {
    func countOfQrCode() -> Int
    func getQrCodeString(for index: IndexPath) -> String
    func getQrCodeDate(for index: IndexPath) -> String
    func fetchAllQrCodes()
    func fetchQrCodes() -> [QrCode]
    
    func deleteCode(index: IndexPath)
    init(view: HistoryScreenViewProtocol, router: RouterProtocol)
}

final class HistoryScreenPresenter: HistoryScreenPresenterProtocol {
    var model = ModelData()
    weak var view: HistoryScreenViewProtocol?
    var router: RouterProtocol?
    var qrCode: [QrCode]?
    
    init(view: HistoryScreenViewProtocol, router: RouterProtocol) {
        self.view = view
        self.router = router
    }
    
    func fetchAllQrCodes() {
        qrCode = model.getAllQrCodes().reversed()
        view?.reloadTable()
    }
    
    func fetchQrCodes() -> [QrCode] {
        qrCode = model.getAllQrCodes()
        return qrCode ?? []
    }
    
    func countOfQrCode() -> Int {
        qrCode?.count ?? 0
    }
    
    func getQrCodeString(for index: IndexPath) -> String {
        return qrCode?[index.row].name ?? ""
    }
    
    func getQrCodeDate(for index: IndexPath) -> String {
         return qrCode?[index.row].date ?? ""
    }
    
    func deleteCode(index: IndexPath) {
        guard let code = qrCode?[index.row] else { return }
        model.deleteCode(code: code)
        fetchAllQrCodes()
    }
}
