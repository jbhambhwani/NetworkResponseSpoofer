//
//  URLExtension.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 8/3/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

extension URL {
    // MARK: - Public properties

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

private extension URL {
    var normalizedURLString: String? {
        // If the host is empty, take an early exit
        guard var result = host else { return nil }

        result.removeWWW()
        result.normalizeSubDomains()

        // Set the port if one existed
        if let port = port {
            result += ":" + String(port)
        }

        // Set the path, replace path ranges & normalize
        result += path
        result.replacePathRanges()
        result.normalizePathComponents()

        // Return current processed URL if there are no query items
        guard query != nil else { return result }

        // Normalize Query Parameters
        let normalizedQueryItems = allQueryItems.filter { Spoofer.queryParametersToNormalize.contains($0.name) == false }
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

private extension String {
    // Remove www prefix
    mutating func removeWWW() {
        if let wwwRange = range(of: "www.") {
            replaceSubrange(wwwRange, with: "")
        }
    }

    // Remove sub domains which are to be normalized from the host name part. e.g. DEV, QA, PREPROD etc.
    mutating func normalizeSubDomains() {
        for subDomainToNormalize in Spoofer.subDomainsToNormalize {
            if let ignoredRange = self.range(of: subDomainToNormalize + ".") {
                removeSubrange(ignoredRange)
            }
            if let ignoredRange = self.range(of: subDomainToNormalize) {
                removeSubrange(ignoredRange)
            }
        }
    }

    mutating func replacePathRanges() {
        for pathRange in Spoofer.pathRangesToReplace {
            if let startRange = self.range(of: pathRange.start + "/") {
                let endRange: Range<String.Index>
                if let end = pathRange.end {
                    endRange = range(of: "/" + end, range: startRange.upperBound ..< endIndex) ?? endIndex ..< endIndex
                } else {
                    endRange = endIndex ..< endIndex
                }
                print(startRange.upperBound)
                print(endRange.lowerBound)
                replaceSubrange(startRange.upperBound ..< endRange.lowerBound, with: pathRange.replacement)
            }
        }

        // Fix other anomalies as part of the replacement; double slashes and end slashes
        self = replacingOccurrences(of: "//", with: "/")
        if last == "/" {
            self = String(dropLast())
        }
    }

    // Remove path components which are to be ignored from the URL. e.g. V1, V2.1 etc.
    mutating func normalizePathComponents() {
        for pathComponent in Spoofer.pathComponentsToNormalize {
            if let pathComponentRange = self.range(of: "/" + pathComponent) {
                removeSubrange(pathComponentRange)
            }
        }
    }

    // Normalize the query parameters
    mutating func normalizeQuery(items: [URLQueryItem]) {
        if Spoofer.normalizeQueryValues {
            let queryItemNames = normalizedQueryItemNames(items)
            if !queryItemNames.isEmpty {
                self += "?" + queryItemNames
            }
        } else {
            let combinedQueryItems = items.reduce("") {
                guard let value = $1.value else { return $0 }
                if !$0.isEmpty {
                    return $0 + "&" + $1.name + "=" + value
                } else {
                    return $0 + $1.name + "=" + value
                }
            }
            if !combinedQueryItems.isEmpty {
                self += "?" + combinedQueryItems
            }
        }
    }

    func normalizedQueryItemNames(_ queryItems: [URLQueryItem]) -> String {
        return queryItems.compactMap { $0.name }.joined(separator: "&")
    }
}
