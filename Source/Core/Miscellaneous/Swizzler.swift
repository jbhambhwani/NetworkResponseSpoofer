//
//  Swizzler.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 6/29/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

// Enable Swizzling for all NSObject subclasses

extension NSObject {
    class func swizzleMethod(_ originalSelector: Selector, withSelector: Selector) {
        let aClass: AnyClass! = object_getClass(self)
        NSObject.swizzleMethod(originalSelector, withSelector: withSelector, forClass: aClass)
    }

    private class func swizzleMethod(_ originalSelector: Selector, withSelector: Selector, forClass: AnyClass) {
        let originalMethod = class_getClassMethod(forClass, originalSelector)
        let swizzledMethod = class_getClassMethod(forClass, withSelector)
        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}
