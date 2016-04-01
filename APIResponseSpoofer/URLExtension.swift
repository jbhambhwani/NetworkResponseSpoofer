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
        // Normalization strips the values from query paramaters and only uses query item names (also filter ignored params)
        let allQueryItemsNames = queryItems.map{ $0.name }.filter{ element in
            !Spoofer.queryParametersToIgnore.contains(element)
        }
        let normalizedNames = "?" + allQueryItemsNames.joinWithSeparator("&")
        return normalizedNames
    }
    
    // MARK:- Public properties
    
    var normalizedURLString: String? {
    
        // If the host is empty, take an early exit
        guard var normalizedString = host else { return nil }
        
        if normalizedString.hasPrefix("www.") {
            let wwwIndex = normalizedString.startIndex.advancedBy(4)
            normalizedString = normalizedString.substringFromIndex(wwwIndex)
        }
        
        // Lower case the string to avoid euality check issues
        normalizedString = normalizedString.lowercaseString
        
        // Remove sub domains which are to be ignored from the host name part. e.g. DEV, QA, PREPROD etc.
        for subDomainToIgnore in Spoofer.subDomainsToIgnore {
            if let ignoredRange = normalizedString.rangeOfString(subDomainToIgnore + ".") {
                normalizedString.removeRange(ignoredRange)
            }
            if let ignoredRange = normalizedString.rangeOfString(subDomainToIgnore) {
                normalizedString.removeRange(ignoredRange)
            }
        }

        // Set the port if one existed
        if let portString = port?.stringValue {
            normalizedString += ":" + portString
        }
        
        // Set the path
        if let pathString = path {
            normalizedString += pathString
        }
        
        // Remove path components which are to be ignored from the URL. e.g. V1, V2.1 etc.
        for pathComponent in Spoofer.pathComponentsToIgnore {
            if let ignoredRange = normalizedString.rangeOfString("/" + pathComponent) {
                normalizedString.removeRange(ignoredRange)
            }
        }
        
        // Return current processed URL if there are no query items
        guard let query = query else { return normalizedString.lowercaseString }

        // Normalize and append query parameter names (ignore values if normalization is requested)
        if let queryItemNames = normalizedQueryItemNames where Spoofer.normalizeQueryParameters {
            normalizedString += queryItemNames
        } else {
            if let fragment = fragment {
                normalizedString += "?" + query + "#" + fragment
            } else {
                normalizedString += "?" + query
            }
        }
        
        return normalizedString.lowercaseString
    }
    
    var isHTTP: Bool {
        return ["http", "https"].contains(scheme)
    }
    
}
