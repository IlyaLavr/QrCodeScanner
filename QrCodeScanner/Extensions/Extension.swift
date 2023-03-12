//
//  Extension.swift
//  QrCodeScanner
//
//  Created by Илья on 12.03.2023.
//

import Foundation
import WebKit

extension WKWebView {
    func exportAsPdfFromWebView() -> NSData {
        let pdfData = createPdfFile(printFormatter: self.viewPrintFormatter())
        return pdfData
    }
    
    func createPdfFile(printFormatter: UIViewPrintFormatter) -> NSMutableData {
        let originalBounds = self.bounds
        self.bounds = CGRect(x: originalBounds.origin.x,
                             y: bounds.origin.y,
                             width: self.bounds.size.width,
                             height: self.scrollView.contentSize.height)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width,
                                  height: self.scrollView.contentSize.height)
        
        let printPageRenderer = UIPrintPageRenderer()
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        printPageRenderer.setValue(NSValue(cgRect: UIScreen.main.bounds), forKey: "paperRect")
        printPageRenderer.setValue(NSValue(cgRect: pdfPageFrame), forKey: "printableRect")
        self.bounds = originalBounds
        return printPageRenderer.generatePdfData()
    }
}

extension UIPrintPageRenderer {
    func generatePdfData() -> NSMutableData {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, self.paperRect, nil)
        self.prepare(forDrawingPages: NSMakeRange(0, self.numberOfPages))
        let printRect = UIGraphicsGetPDFContextBounds()
        for pdfPage in 0..<self.numberOfPages {
            UIGraphicsBeginPDFPage()
            self.drawPage(at: pdfPage, in: printRect)
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
}
