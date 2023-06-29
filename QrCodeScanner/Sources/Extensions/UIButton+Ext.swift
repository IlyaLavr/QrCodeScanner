//
//  UIButton+Ext.swift
//  QrCodeScanner
//
//  Created by Илья on 30.06.2023.
//

import UIKit

extension UIButton {
    private struct AssociatedKeys {
        static var hitTestEdgeInsets = "hitTestEdgeInsets"
    }
    
    var hitTestEdgeInsets: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.hitTestEdgeInsets) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.hitTestEdgeInsets, newValue as UIEdgeInsets?, .OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let hitTestEdgeInsets = hitTestEdgeInsets {
            let hitFrame = bounds.inset(by: hitTestEdgeInsets)
            return hitFrame.contains(point)
        }
        return super.point(inside: point, with: event)
    }
}
