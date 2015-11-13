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

class Scenario : NSObject, NSCoding {
    
    let name: String
    var apiResponses = [APIResponse]()
    
    // MARK -
    init(name: String = "Default") {
        self.name = name
    }
    
    // MARK: - Managing responses
    func addResponse(response: APIResponse) {
        if let existingResponseIndex = apiResponses.indexOf(response) {
            // If a response matching the same normalized URL exists, remove and replace it with the new response (so that we keep latest)
            apiResponses.removeAtIndex(existingResponseIndex)
        }
        apiResponses.append(response)
        postNotification("Response received:\n\(response)", object: self)
    }
    
    func responseForRequest(urlRequest: NSURLRequest) -> APIResponse? {
        let normalizedInputURL = urlRequest.URL?.normalizedURLString
        for response in apiResponses {
            if response.requestURL.normalizedURLString ==  normalizedInputURL {
                return response
            }
        }
        return nil
    }
    
    subscript(urlRequest: NSURLRequest) -> APIResponse? {
        return responseForRequest(urlRequest)
    }
    
    // MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(ScenarioFields.name) as! String
        apiResponses = aDecoder.decodeObjectForKey(ScenarioFields.responses) as! [APIResponse]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: ScenarioFields.name)
        aCoder.encodeObject(apiResponses, forKey: ScenarioFields.responses)
    }
    
}

// MARK: Helper methods for debugging
extension Scenario: CustomDebugStringConvertible {
    override var description: String { return "Scenario: \(name)"}
    override var debugDescription: String { return "Scenario: \(name)\nResponses: \(apiResponses)\n"}
}
