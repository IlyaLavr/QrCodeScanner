//
//  ExtensionUIPrintPageRenderer.swift
//  QrCodeScanner
//
//  Created by Илья on 20.03.2023.
//

import UIKit

extension UIPrintPageRenderer {
    func generatePdfData() -> NSMutableData {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        self.prepare(forDrawingPages: NSMakeRange(0, numberOfPages))
        let printRect = UIGraphicsGetPDFContextBounds()
        for pdfPage in 0..<self.numberOfPages {
            UIGraphicsBeginPDFPage()
            drawPage(at: pdfPage, in: printRect)
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
}
