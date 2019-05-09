//
//  URLSessionConfigurationExtension.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 6/29/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

// Global property contains swizzle code in a call to a closure. Will be initialized only once the first time it is used
private let swizzleURLSessionConfiguration: Void = {
//    NSObject.swizzleMethod(#selector(URLSessionConfiguration.spoofedDefault),
//                           withSelector: #selector(getter: URLSessionConfiguration.default))
//    NSObject.swizzleMethod(#selector(URLSessionConfiguration.spoofedEphemeral),
//                           withSelector: #selector(getter: URLSessionConfiguration.ephemeral))

    Swizzler.swizzleClassMethod(of: URLSessionConfiguration.self,
                                from: #selector(URLSessionConfiguration.spoofedDefault),
                                to: #selector(getter: URLSessionConfiguration.default))

    Swizzler.swizzleClassMethod(of: URLSessionConfiguration.self,
                                from: #selector(URLSessionConfiguration.spoofedEphemeral),
                                to: #selector(getter: URLSessionConfiguration.ephemeral))

}()

public extension URLSessionConfiguration {
    /*
     URLSessionConfiguration by default vends a new session config every time we request for one.
     The previous method of URLProtocol.registerClass does not work with these configs as they have an array of protocol
     classes that we need to add our protocols to (To the start, since we wan't the intercept to be prioritized.
     Also most apps spawn URLSessions and Configurations on demand, and do not dependency inject it through the stack.
     This creates a problem for the spoofer, which needs to intercept HTTP requests so that it can record or replay them.

     The below implementation circumvents that issue by swizzling the default and ephemeral configurations to route
     through new methods, allowing us to insert the recording and replaying protocols to any such spawned session configuration.
     */

    /// Spoofed Default URLSessionConfiguration (As a property)
    static var spoofed: URLSessionConfiguration {
        let sessionConfig = URLSessionConfiguration.default
        insertInterceptors(inConfig: sessionConfig)
        return sessionConfig
    }

    /// Swizzle URLSessionConfiguration to insert Spoofer Interceptor protocols
    class func swizzleConfiguration() {
        _ = swizzleURLSessionConfiguration
    }

    /// Spoofed Default URLSessionConfiguration (As a method)
    @objc class func spoofedDefault() -> URLSessionConfiguration {
        let config = spoofedDefault()
        insertInterceptors(inConfig: config)
        return config
    }

    /// Spoofed Ephemeral URLSessionConfiguration
    @objc class func spoofedEphemeral() -> URLSessionConfiguration {
        let config = spoofedEphemeral()
        insertInterceptors(inConfig: config)
        return config
    }

    private class func insertInterceptors(inConfig config: URLSessionConfiguration) {
        var protocolClasses = config.protocolClasses
        protocolClasses?.insert(SpooferRecorder.self, at: 0)
        protocolClasses?.insert(SpooferReplayer.self, at: 0)
        config.protocolClasses = protocolClasses
    }
}
