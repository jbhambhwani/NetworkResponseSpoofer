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
                let allQueryItemsNames = map(queryItems){return $0.name}
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
            if let queryItemNames = self.normalizedQueryItemNames {
                normalizedString += queryItemNames
            }
            return normalizedString
        }
    }
    
}
