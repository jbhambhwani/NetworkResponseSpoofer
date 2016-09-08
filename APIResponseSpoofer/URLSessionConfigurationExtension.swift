//
//  URLSessionConfigurationExtension.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 6/29/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

fileprivate let swizzleURLSessionConfiguration = {
    NSObject.swizzleMethod(#selector(URLSessionConfiguration.spoofedDefault),
                  withSelector: #selector(getter: URLSessionConfiguration.default))
    NSObject.swizzleMethod(#selector(URLSessionConfiguration.spoofedEphemeral),
                  withSelector: #selector(getter: URLSessionConfiguration.ephemeral))
}

// Swizzle URLSessionConfiguration to insert our Interceptor protocols

extension URLSessionConfiguration {
    
    /*  NSURLSessionConfiguration by default vends a new session config every time we request for one. The previous method of NSURLProtocol.registerClass does not work with these configs as they have an array of protocol classes that we need to add our protocols to (To the start, since we wan't the intercept to be prioritized. Also most apps spawn NSURLSessions and Configurations on demand, and do not dependency inject it through the stack. This creates a problem for the spoofer, which needs to intercept HTTP requests so that it can record or replay them. 
     
        The below implementation circumvents that issue by swizzling the default and ephemeral configurations to route through new methods, allowing us to insert the recording and replaying protocols to any such spawned session configuration.
    */
    
    class func swizzleConfiguration() {
        _ = swizzleURLSessionConfiguration()
    }
    
    internal class func spoofedDefault() -> URLSessionConfiguration {
        let config = self.spoofedDefault()
        insertInterceptors(inConfig: config)
        return config
    }
    
    internal class func spoofedEphemeral() -> URLSessionConfiguration {
        let config = self.spoofedEphemeral()
        insertInterceptors(inConfig: config)
        return config
    }
    
    private class func insertInterceptors(inConfig config: URLSessionConfiguration) {
        var protocolClasses = config.protocolClasses
        protocolClasses?.insert(RecordingProtocol.self, at: 0)
        protocolClasses?.insert(ReplayingProtocol.self, at: 0)
        config.protocolClasses = protocolClasses
    }
    
}
