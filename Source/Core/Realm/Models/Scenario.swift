//
//  Scenario.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 10/28/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

class Scenario: Object {
    @objc dynamic var name = "Default"
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
        guard let requestURLString = urlRequest.url?.normalizedString else { return nil }
        let matchingResponses = apiResponses.filter { savedResponse in
            guard let savedURL = URL(string: savedResponse.requestURL),
                let normalizedSavedURL = savedURL.normalizedString else { return false }
            return normalizedSavedURL.contains(requestURLString)
        }

        return matchingResponses.first
    }

    subscript(urlRequest: URLRequest) -> APIResponse? {
        return responseForRequest(urlRequest)
    }
}

// MARK: Helper methods for debugging

extension Scenario {
    override var description: String { return "Scenario: \(name)" }
    override var debugDescription: String { return "Scenario: \(name)\nResponses: \(apiResponses)\n" }
}
