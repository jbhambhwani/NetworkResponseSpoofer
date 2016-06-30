//
//  NetworkInterceptable.swift
//  Pods
//
//  Created by Deepu Mukundan on 6/28/16.
//
//

import Foundation

/// Protocol to be adopted by NSURLProtocol adopters to simplify the intercept setup process
protocol NetworkInterceptable: class {
    static func startIntercept() -> Bool
    static func stopIntercept()
}

extension NetworkInterceptable {
    
    static func startIntercept() -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(Self)
        // Swizzle will only happen once due to dispatch_once block inside
        NSURLSessionConfiguration.swizzleConfiguration()
        return protocolRegistered
    }
    
    static func stopIntercept() {
        NSURLProtocol.unregisterClass(Self)
    }
    
}