//
//  Network.swift
//  QrCodeScanner
//
//  Created by Илья on 14.03.2023.
//

import UIKit

class Network {
    static let shared = Network()
    
    func searchProductByCode(_ code: String) {
        let baseUrl = "https://www.yandex.com/search"
        let query = "\(code)"
        let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "\(baseUrl)?text=\(escapedQuery)"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        UIApplication.shared.open(url)
    }
    
    func openLinkInBrowser(_ text: String) {
        let urlString = "\(text)"
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL")
            return
        }
        UIApplication.shared.open(url)
    }
}
