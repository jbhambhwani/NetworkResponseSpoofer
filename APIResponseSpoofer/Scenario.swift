//
//  Scenario.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/29/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

struct ScenarioFields {
    static let name = "name"
    static let responses = "responses"
}

class Scenario: NSObject, NSCoding {
    
    let name: String
    var apiResponses = [APIResponse]()
    
    init(name: String = "Default") {
        self.name = name
    }
    
    // MARK: - Managing responses
    
    func addResponse(_ response: APIResponse) {
        if let existingResponseIndex = apiResponses.index(of: response) {
            // If a response matching the same normalized URL exists, remove and replace it with the new response (so that we keep latest)
            apiResponses.remove(at: existingResponseIndex)
        }
        apiResponses.append(response)
        postNotification("Response received:\n\(response)", object: self)
    }
    
    func responseForRequest(_ urlRequest: URLRequest) -> APIResponse? {
        guard let requestURLString = urlRequest.url?.normalizedURLString else { return nil }
        let response = apiResponses.filter { savedResponse in
            guard let savedURLString = savedResponse.requestURL.normalizedURLString else { return false }
            return savedURLString.contains(requestURLString)
        }.first
        return response
    }
    
    subscript(urlRequest: URLRequest) -> APIResponse? {
        return responseForRequest(urlRequest)
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: ScenarioFields.name) as! String
        apiResponses = aDecoder.decodeObject(forKey: ScenarioFields.responses) as! [APIResponse]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: ScenarioFields.name)
        aCoder.encode(apiResponses, forKey: ScenarioFields.responses)
    }
    
}

// MARK: Helper methods for debugging
extension Scenario {
    override var description: String { return "Scenario: \(name)"}
    override var debugDescription: String { return "Scenario: \(name)\nResponses: \(apiResponses)\n"}
}
