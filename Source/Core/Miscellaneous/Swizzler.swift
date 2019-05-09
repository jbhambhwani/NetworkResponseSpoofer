//
//  Swizzler.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 6/29/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import ObjectiveC

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

struct Swizzler {
    /// Swizzle Instance method
    public static func swizzleInstanceMethod(of classType: AnyClass, from selector1: Selector, to selector2: Selector) {
        swizzleMethod(of: classType, from: selector1, to: selector2, isClassMethod: false)
    }

    /// Swizzle class method
    public static func swizzleClassMethod(of classType: AnyClass, from selector1: Selector, to selector2: Selector) {
        swizzleMethod(of: classType, from: selector1, to: selector2, isClassMethod: true)
    }
}

private extension Swizzler {
    static func swizzleMethod(of classType: AnyClass, from selector1: Selector, to selector2: Selector, isClassMethod: Bool) {
        let swizzledClass: AnyClass
        if isClassMethod {
            guard let cla = object_getClass(classType) else {
                return
            }
            swizzledClass = cla
        } else {
            swizzledClass = classType
        }

        guard let method1: Method = class_getInstanceMethod(swizzledClass, selector1),
            let method2: Method = class_getInstanceMethod(swizzledClass, selector2) else {
            return
        }

        if class_addMethod(swizzledClass, selector1, method_getImplementation(method2), method_getTypeEncoding(method2)) {
            class_replaceMethod(swizzledClass, selector2, method_getImplementation(method1), method_getTypeEncoding(method1))
        } else {
            method_exchangeImplementations(method1, method2)
        }
    }
}
