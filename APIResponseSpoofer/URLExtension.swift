//
//  URLExtension.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/3/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

extension NSURL {
    
    // MARK: - Private properties
    private var allQueryItems: [NSURLQueryItem]? {
        guard let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = components.queryItems else { return nil }
        return queryItems
    }
    
    private var normalizedQueryItemNames: String? {
        guard let queryItems = allQueryItems else { return nil }
        // Normalization strips the values from query paramaters and only uses item names (also filter ignored params)
        let allQueryItemsNames = queryItems.map{ $0.name }.filter{ element in
            !Spoofer.parametersToIgnore.contains(element)
        }
        let normalizedNames = "?" + allQueryItemsNames.joinWithSeparator("&")
        return normalizedNames
    }
    
    // MARK: Public properties
    var normalizedURLString: String? {
        // If the host is empty, take an early exit
        guard var normalizedString = self.host else { return nil }
        // Append the path
        if let pathString = self.path {
            normalizedString += pathString
        }
        // Normalize and append query parameter names (ignore values)
        if let queryItemNames = self.normalizedQueryItemNames {
            normalizedString += queryItemNames
        }
        return normalizedString
    }
    
    var isHTTP: Bool {
        return ["http","https"].contains(self.scheme)
    }
    
}
