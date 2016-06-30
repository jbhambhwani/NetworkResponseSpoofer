//
//  NetworkInterceptable.swift
//  Pods
//
//  Created by Deepu Mukundan on 6/28/16.
//
//

import Foundation

protocol NetworkInterceptable: class {
    static func startIntercept() -> Bool
    static func stopIntercept()
}

extension NetworkInterceptable {
    
    static func startIntercept() -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(Self)
        NSURLSessionConfiguration.swizzleConfiguration()
        return protocolRegistered
    }
    
    static func stopIntercept() {
        NSURLProtocol.unregisterClass(Self)
    }
    
}