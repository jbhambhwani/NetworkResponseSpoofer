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

    /// Swizzle URLSessionConfiguration to insert Spoofer Interceptor protocols
    class func swizzleConfiguration() {
        _ = swizzleURLSessionConfiguration
    }

    class func insertInterceptors(inConfig config: URLSessionConfiguration) {
        var protocolClasses = config.protocolClasses
        protocolClasses?.removeAll {
            $0 == SpooferRecorder.self || $0 == SpooferReplayer.self
        }
        protocolClasses?.insert(SpooferRecorder.self, at: 0)
        protocolClasses?.insert(SpooferReplayer.self, at: 0)
        config.protocolClasses = protocolClasses
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
}
