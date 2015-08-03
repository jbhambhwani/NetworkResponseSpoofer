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
    
    // MARK: - 
    init(name: String = "Default") {
        self.name = name
    }
    
    func addResponse(response: APIResponse) {
        apiResponses.append(response)
        println("-----------------------------------------------------------------------------------------------")
        println("Response received:\n\(response)")
    }
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey(ScenarioFields.name) as! String
        apiResponses = aDecoder.decodeObjectForKey(ScenarioFields.responses) as! [APIResponse]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: ScenarioFields.name)
        aCoder.encodeObject(apiResponses, forKey: ScenarioFields.responses)
    }
    
    func responseForRequest(urlRequest: NSURLRequest) -> APIResponse? {
        for response in apiResponses {
            // TODO: Create Normalize the url's by stripping out query parameter values. Compare based only on host and query parameters
            if response.requestURL == urlRequest.URL {
                return response
            }
        }
        return nil
    }
    
}

// MARK: Helper methods for debugging
extension Scenario: DebugPrintable, Printable {
    override var description: String { return " Scenario: \(name)"}
    override var debugDescription: String { return " Scenario: \(name)\n Responses: \(apiResponses)\n"}
}
