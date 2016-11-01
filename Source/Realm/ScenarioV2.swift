//
//  ScenarioV2.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/28/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

class ScenarioV2: Object {
    
    dynamic var name = "Default"
    let apiResponses = List<APIResponseV2>()
}

extension ScenarioV2 {
    
    func addResponse(_ response: APIResponseV2) {
        // apiResponses = apiResponses.filter { $0.requestURL != response.requestURL }
        apiResponses.append(response)
        postNotification("Response received:\n\(response)", object: self)
    }
    
    func responseForRequest(_ urlRequest: URLRequest) -> APIResponseV2? {
        guard let requestURLString = urlRequest.url?.normalizedURLString else { return nil }
        let response = apiResponses.filter { savedResponse in
            return savedResponse.requestURL.contains(requestURLString)
            }.first
        return response
    }
    
    subscript(urlRequest: URLRequest) -> APIResponseV2? {
        return responseForRequest(urlRequest)
    }
    
}

// MARK: Helper methods for debugging
extension ScenarioV2 {
    override var description: String { return "Scenario: \(name)"}
    override var debugDescription: String { return "Scenario: \(name)\nResponses: \(apiResponses)\n"}
}
