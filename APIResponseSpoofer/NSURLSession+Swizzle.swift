//
//  NSURLSession+Swizzle.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 6/29/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

// Swizzle NSURLSessionConfiguration to insert our Interceptor protocols

public extension NSURLSessionConfiguration {
    
    private struct Static {
        static var token: dispatch_once_t = 0
    }
    
    class func swizzleConfiguration() {
        dispatch_once(&Static.token) {
            swizzleMethod(#selector(NSURLSessionConfiguration.spoofedDefaultSessionConfiguration),
                          withSelector: #selector(NSURLSessionConfiguration.defaultSessionConfiguration))
            swizzleMethod(#selector(NSURLSessionConfiguration.spoofedEphemeralSessionConfiguration),
                          withSelector: #selector(NSURLSessionConfiguration.ephemeralSessionConfiguration))
        }
    }
    
    internal class func spoofedDefaultSessionConfiguration() -> NSURLSessionConfiguration {
        let config = self.spoofedDefaultSessionConfiguration()
        insertInterceptors(inConfig: config)
        return config
    }
    
    internal class func spoofedEphemeralSessionConfiguration() -> NSURLSessionConfiguration {
        let config = self.spoofedEphemeralSessionConfiguration()
        insertInterceptors(inConfig: config)
        return config
    }
    
    private class func insertInterceptors(inConfig config: NSURLSessionConfiguration) {
        var protocolClasses = config.protocolClasses
        protocolClasses?.insert(RecordingProtocol.self, atIndex: 0)
        protocolClasses?.insert(ReplayingProtocol.self, atIndex: 0)
        config.protocolClasses = protocolClasses
    }
    
}
