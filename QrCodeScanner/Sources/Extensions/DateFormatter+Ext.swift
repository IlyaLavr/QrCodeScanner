//
//  DateFormatter+Ext.swift
//  QrCodeScanner
//
//  Created by Илья on 30.06.2023.
//

import Foundation

extension DateFormatter {
    static func localizedDateString(from date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale(identifier: "ru_RU")
        dateFormat.dateFormat = "d MMMM yyyy 'г.' HH:mm:ss"
        return dateFormat.string(from: date)
    }
}
