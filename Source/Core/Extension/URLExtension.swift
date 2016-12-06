//
//  URLExtension.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/3/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

extension URL {
    
    // MARK:- Public properties

    var normalizedString: String? {

        // Lower case the URL string to avoid euality check issues
        let lowercasedURL = URL(string: absoluteString.lowercased())
        return lowercasedURL?.normalizedURLString
    }

    var isHTTP: Bool {
        guard let scheme = scheme else { return false }
        return ["http", "https"].contains(scheme)
    }
    
}

// MARK: - Private properties

fileprivate extension URL {

    var normalizedURLString: String? {

        // If the host is empty, take an early exit
        guard var result = host else { return nil }

        result.removeWeb()
        result.normalizeSubDomains()

        // Set the port if one existed
        if let port = port {
            result += ":" + String(port)
        }

        // Set the path & normalize
        result += path
        result.normalizePathComponents()

        // Return current processed URL if there are no query items
        guard let _ = query else { return result }

        // Normalize Query Parameters
        let normalizedQueryItems = allQueryItems.filter({ Spoofer.queryParametersToNormalize.contains($0.name) == false })
        result.normalizeQuery(items: normalizedQueryItems)

        if let fragment = fragment {
            result += "#" + fragment
        }

        return result
    }

    var allQueryItems: [URLQueryItem] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return [] }
        guard let queryItems = components.queryItems else { return [] }
        return queryItems
    }
    
}

fileprivate extension String {
    
    // Remove www prefix
    mutating func removeWeb() {
        if self.hasPrefix("www.") {
            let wwwIndex = self.index(self.startIndex, offsetBy: 4)
            self = self.substring(from: wwwIndex)
        }
    }
    
    // Remove sub domains which are to be normalized from the host name part. e.g. DEV, QA, PREPROD etc.
    mutating func normalizeSubDomains() {
        for subDomainToNormalize in Spoofer.subDomainsToNormalize {
            if let ignoredRange = self.range(of: subDomainToNormalize + ".") {
                self.removeSubrange(ignoredRange)
            }
            if let ignoredRange = self.range(of: subDomainToNormalize) {
                self.removeSubrange(ignoredRange)
            }
        }
    }
    
    // Remove path components which are to be ignored from the URL. e.g. V1, V2.1 etc.
    mutating func normalizePathComponents() {
        for pathComponent in Spoofer.pathComponentsToNormalize {
            if let pathComponentRange = self.range(of: "/" + pathComponent) {
                self.removeSubrange(pathComponentRange)
            }
        }
    }
    
    // Normalize the query parameters
    mutating func normalizeQuery(items: [URLQueryItem]) {
        if Spoofer.normalizeQueryValues {
            let queryItemNames = normalizedQueryItemNames(items)
            if queryItemNames.characters.count > 0 {
                self += "?" + queryItemNames
            }
        } else {
            let combinedQueryItems = items.reduce(""){
                guard let value = $1.value else { return $0 }
                if $0.characters.count > 0 {
                    return $0 + "&" + $1.name + "=" + value
                } else {
                    return $0 + $1.name + "=" + value
                }
            }
            if combinedQueryItems.characters.count > 0 {
                self += "?" + combinedQueryItems
            }
        }
    }

    func normalizedQueryItemNames(_ queryItems: [URLQueryItem]) -> String {
        return queryItems.flatMap({ $0.name }).joined(separator: "&")
    }
}
