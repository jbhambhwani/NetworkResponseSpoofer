//
//  Scenario.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 10/28/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class Scenario: Object {
    @objc public dynamic var name = "Default"
    public let networkResponses = List<NetworkResponse>()

    public override static func primaryKey() -> String {
        return "name"
    }

    public override static func indexedProperties() -> [String] {
        return ["name"]
    }
}

extension Scenario {
    func responseForRequest(_ urlRequest: URLRequest) -> NetworkResponse? {
        guard let requestURLString = urlRequest.url?.normalizedString else { return nil }
        let matchingResponses = networkResponses.filter { savedResponse in
            guard let savedURL = URL(string: savedResponse.requestURL),
                let normalizedSavedURL = savedURL.normalizedString else { return false }
            return normalizedSavedURL.contains(requestURLString)
        }

        let matchingUnserved = matchingResponses.filter { $0.servedToClient == false }
        if let exactMatch = matchingUnserved.first {
            // Return the first unserved response if any so that we can process in sequence
            _ = DataStore.markAsServed(response: exactMatch)
            return exactMatch
        } else {
            // Else return the last match from all responses (served already, re-serving now onwards)
            return matchingResponses.last
        }
    }

    subscript(urlRequest: URLRequest) -> NetworkResponse? {
        return responseForRequest(urlRequest)
    }
}

// MARK: Helper methods for debugging

extension Scenario {
    public override var description: String { return "Scenario: \(name)" }
    public override var debugDescription: String { return "Scenario: \(name)\nResponses: \(networkResponses)\n" }
}
