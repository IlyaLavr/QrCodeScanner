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
        let pdfData = createPdfFile(printFormatter: viewPrintFormatter())
        return pdfData
    }
    
    func createPdfFile(printFormatter: UIViewPrintFormatter) -> NSMutableData {
        let originalBounds = bounds
        bounds = CGRect(x: originalBounds.origin.x,
                        y: bounds.origin.y,
                        width: bounds.size.width,
                        height: scrollView.contentSize.height)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: bounds.size.width,
                                  height: scrollView.contentSize.height)
        
        let printPageRenderer = UIPrintPageRenderer()
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        printPageRenderer.setValue(NSValue(cgRect: UIScreen.main.bounds), forKey: "paperRect")
        printPageRenderer.setValue(NSValue(cgRect: pdfPageFrame), forKey: "printableRect")
        bounds = originalBounds
        return printPageRenderer.generatePdfData()
    }
}
