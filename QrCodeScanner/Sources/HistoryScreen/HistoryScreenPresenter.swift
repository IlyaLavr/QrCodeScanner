//
//  HistoryScreenPresenter.swift
//  QrCodeScanner
//
//  Created by Илья on 22.03.2023.
//

import Foundation

protocol HistoryScreenPresenterProtocol: AnyObject {
    func countOfQrCodeWhithoutImage() -> Int
    func getQrCodeString(for index: IndexPath) -> String
    func getQrCodeDate(for index: IndexPath) -> String
    func fetchAllQrCodes()
    func fetchQrCodesWithImage() -> [QrCode]
    func countOfQrCodeWithImage() -> Int
    func deleteCode(index: IndexPath)
    func deleteCodeWithImage(index: IndexPath)
    func showDetail(code index: IndexPath)
    func showDetailGeneratedCode(code index: IndexPath)
    
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
    
    func fetchQrCodesWithImage() -> [QrCode] {
        qrCode = model.getAllQrCodes().reversed()
        return qrCode?.filter { $0.image != nil } ?? []
    }
    
    func countOfQrCodeWhithoutImage() -> Int {
        qrCode?.filter { $0.image == nil }.count ?? 0
    }
    
    func countOfQrCodeWithImage() -> Int {
        qrCode?.filter { $0.image != nil }.count ?? 0
    }
    
    func getQrCodeString(for index: IndexPath) -> String {
        return qrCode?.filter { $0.image == nil }[index.row].name ?? ""
    }
    
    func getQrCodeDate(for index: IndexPath) -> String {
        return qrCode?.filter { $0.image == nil }[index.row].date ?? ""
    }
    
    func deleteCode(index: IndexPath) {
        guard let code = qrCode?.filter({ $0.image == nil })[index.row] else { return }
        model.deleteCode(code: code)
        fetchAllQrCodes()
    }
    
    func deleteCodeWithImage(index: IndexPath) {
        guard let code = qrCode?.filter({ $0.image != nil })[index.row] else { return }
        model.deleteCode(code: code)
        fetchAllQrCodes()
    }
    
    func showDetail(code index: IndexPath) {
        guard let code = qrCode?.filter({ $0.image == nil })[index.row] else { return }
        router?.showDetailScanCode(code: code)
    }
    
    func showDetailGeneratedCode(code index: IndexPath) {
        guard let code = qrCode?.filter({ $0.image != nil })[index.row] else { return }
        router?.showDetailGeneratedCode(code: code)
    }
}
