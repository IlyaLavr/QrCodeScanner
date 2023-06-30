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
    
    static func showAlert(type: Alert, okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil, view: UIViewController) {
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
                                  message: "Введите текст или URL для генерации QR кода",
                                  textButtonOk: "Ok",
                                  textButtonCancel: "")
    
    static let saveInGaleryStatus = Alert(title: "Файл будет сохранен в галерее телефона",
                                          message: "Сохранить файл?",
                                          textButtonOk: "Сохранить",
                                          textButtonCancel: "Не сохранять")
    
    static let succefulSaveInGalery = Alert(title: "Файл успешно сохранен в галерею",
                                            message: "",
                                            textButtonOk: "Ok",
                                            textButtonCancel: "")
    static let errorSaveGallery = Alert(title: "Вы не захотели сохранить код",
                                        message: "Но вы можете поделиться им с друзьями!",
                                        textButtonOk: "Ok",
                                        textButtonCancel: "")
    
    static let succefulShare = Alert(title: "Все прошло хорошо!",
                                     message: "Вы успешно поделились QR кодом",
                                     textButtonOk: "Ok",
                                     textButtonCancel: "")
    
    static let errorShare = Alert(title: "Не удалось поделиться файлом",
                                  message: "Попробуйте еще раз или сохраните QR код в галерею",
                                  textButtonOk: "Ok",
                                  textButtonCancel: "")
    
    static let urlCopy = Alert(title: "Ссылка скопирована",
                               message: "",
                               textButtonOk: "Ok",
                               textButtonCancel: "")
}
