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
    
    /*  NSURLSessionConfiguration by default vends a new session config every time we request for one. The previous method of NSURLProtocol.registerClass does not work with these configs as they have an array of protocol classes that we need to add our protocols to (To the start, since we wan't the intercept to be prioritized. Also most apps spawn NSURLSessions and Configurations on demand, and do not dependency inject it through the stack. This creates a problem for the spoofer, which needs to intercept HTTP requests so that it can record or replay them. 
     
        The below implementation circumvents that issue by swizzling the default and ephemeral configurations to route through new methods, allowing us to insert the recording and replaying protocols to any such spawned session configuration.
    */
    
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
