//
//  URLExtension.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/3/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

extension URL {
    
    // MARK: - Private properties
    private var allQueryItems: [URLQueryItem]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = components.queryItems else { return nil }
        return queryItems
    }
    
    private var normalizedQueryItemNames: String? {
        guard let queryItems = allQueryItems else { return nil }
        // Normalization strips the values from query paramaters and only uses query item names (also filter ignored params)
        let allQueryItemsNames = queryItems.map{ $0.name }.filter{ element in
            !Spoofer.queryParametersToIgnore.contains(element)
        }
        let normalizedNames = "?" + allQueryItemsNames.joined(separator: "&")
        return normalizedNames
    }
    
    // MARK:- Public properties
    
    var normalizedURLString: String? {
        
        // If the host is empty, take an early exit
        guard var normalizedString = host else { return nil }
        
        if normalizedString.hasPrefix("www.") {
            let wwwIndex = normalizedString.index(normalizedString.startIndex, offsetBy: 4)
            normalizedString = normalizedString.substring(from: wwwIndex)
        }
        
        // Lower case the string to avoid euality check issues
        normalizedString = normalizedString.lowercased()
        
        // Remove sub domains which are to be ignored from the host name part. e.g. DEV, QA, PREPROD etc.
        for subDomainToIgnore in Spoofer.subDomainsToIgnore {
            if let ignoredRange = normalizedString.range(of: subDomainToIgnore + ".") {
                normalizedString.removeSubrange(ignoredRange)
            }
            if let ignoredRange = normalizedString.range(of: subDomainToIgnore) {
                normalizedString.removeSubrange(ignoredRange)
            }
        }
        
        // Set the port if one existed
        if let port = port {
            normalizedString += ":" + String(port)
        }
        
        // Set the path
        normalizedString += path
        
        // Remove path components which are to be ignored from the URL. e.g. V1, V2.1 etc.
        for pathComponent in Spoofer.pathComponentsToIgnore {
            if let pathComponentRange = normalizedString.range(of: "/" + pathComponent) {
                normalizedString.removeSubrange(pathComponentRange)
            }
        }
        
        // Return current processed URL if there are no query items
        guard let query = query else { return normalizedString.lowercased() }
        
        // Normalize and append query parameter names (ignore values if normalization is requested)
        if let queryItemNames = normalizedQueryItemNames, Spoofer.normalizeQueryParameters == true {
            normalizedString += queryItemNames
        } else {
            if let fragment = fragment {
                normalizedString += "?" + query + "#" + fragment
            } else {
                normalizedString += "?" + query
            }
        }
        
        return normalizedString.lowercased()
    }
    
    var isHTTP: Bool {
        guard let scheme = scheme else { return false }
        return ["http", "https"].contains(scheme)
    }
    
}
