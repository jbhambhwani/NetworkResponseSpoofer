//
//  URLExtension.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/3/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

extension NSURL {
    
    var allQueryItems: [NSURLQueryItem]? {
        get {
            let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false)!
            let allQueryItems = components.queryItems
            return allQueryItems as? [NSURLQueryItem]
        }
    }
    
    var normalizedQueryItemNames: String? {
        get {
            if let queryItems = allQueryItems {
                var allQueryItemsNames = map(queryItems){return $0.name}
                let normalizedNames = "?" + "&".join(allQueryItemsNames)
                return normalizedNames
            }
            return nil
        }
    }
    
    var normalizedURLString: String? {
        get {
            var normalizedString = self.host!
            if let path = self.path {
                normalizedString += path
            }
            // TODO - Enable whitelist/blacklist on query pparameter names and then enable this. Right now there could be cases where even parameters change based on scenario.
            // if let queryItemNames = self.normalizedQueryItemNames {
            //     normalizedString += queryItemNames
            // }
            return normalizedString
        }
    }
    
    var isHTTP: Bool {
        get {
            let isHTTPURL = (self.scheme == "http") || (self.scheme == "https")
            return isHTTPURL
        }
    }
    
}
