//
//  Scenario.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/28/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

class Scenario: Object {
    
    dynamic var name = "Default"
    let apiResponses = List<APIResponse>()
    
    override static func primaryKey() -> String {
        return "name"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}

extension Scenario {
    
    func responseForRequest(_ urlRequest: URLRequest) -> APIResponse? {
        guard let requestURLString = urlRequest.url?.normalizedURLString else { return nil }
        let response = apiResponses.filter { savedResponse in
            guard let savedURL = URL(string: savedResponse.requestURL),
                let normalizedSavedURL = savedURL.normalizedURLString else { return false }
            return normalizedSavedURL.contains(requestURLString)
        }.first
        return response
    }
    
    subscript(urlRequest: URLRequest) -> APIResponse? {
        return responseForRequest(urlRequest)
    }
    
}

// MARK: Helper methods for debugging

extension Scenario {
    override var description: String { return "Scenario: \(name)"}
    override var debugDescription: String { return "Scenario: \(name)\nResponses: \(apiResponses)\n"}
}
