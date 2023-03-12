//
//  odel.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import Foundation
import WebKit

protocol ModelProtocol: AnyObject {
    func exportAsPDF(from webView: WKWebView?) -> NSData?
}

class Model: ModelProtocol {
    func exportAsPDF(from webView: WKWebView?) -> NSData? {
        guard let pdfData = webView?.exportAsPdfFromWebView() else { return nil }
        return pdfData
    }
}
