//
//  AlertView.swift
//  QrCodeScanner
//
//  Created by Илья on 14.03.2023.
//

import UIKit

struct Alert: Equatable {
    var title: String
    var message: String
    var textButtonOk: String
    var textButtonCancel: String
}

final class AlertView {
    static func showAlertStatus(type: Alert, okHandler: ((UIAlertAction) -> Void)? = nil, view: UIViewController) {
        let alert = UIAlertController(title: type.title, message: type.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: type.textButtonOk, style: .default, handler: okHandler))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func showAlert(type: Alert, okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil, view: QrScannerViewController) {
        let alert = UIAlertController(title: type.title, message: type.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: type.textButtonOk, style: .default, handler: okHandler))
        alert.addAction(UIAlertAction(title: type.textButtonCancel, style: .cancel, handler: cancelHandler))
        view.present(alert, animated: true, completion: nil)
    }
}
extension Alert {
    static let succefulSave = Alert(title: "PDF Saved",
                                    message: "Файл был успешно сохранен",
                                    textButtonOk: "Ok",
                                    textButtonCancel: "")
    
    static let  failedSave = Alert(title: "Failed to save PDF",
                                   message: "Не удалось сохранить файл",
                                   textButtonOk: "Ok",
                                   textButtonCancel: "")
    
    static let openBrowser = Alert(title: "Перейти на страницу поиска?",
                                   message: "Будет выполнен поиск штрих-кода в браузере",
                                   textButtonOk: "Перейти",
                                   textButtonCancel: "Отмена")
    
    static let noInternet = Alert(title: "Нет Интернета",
                                  message: "Проверьте соеднение с интернетом",
                                  textButtonOk: "Ok",
                                  textButtonCancel: "")
    
    static let emptyStrig = Alert(title: "Пустая строка",
                                  message: "Введите текст для генерации QR кода",
                                  textButtonOk: "Ok",
                                  textButtonCancel: "")
}
