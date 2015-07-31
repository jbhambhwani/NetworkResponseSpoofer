//
//  Scenario.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/29/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class Scenario : NSObject, NSCoding {
    
    let name: String
    var apiResponses:[Response]?
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory in the application's documents Application Support directory used to store the Scenario files.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    init(name: String = "Default") {
        self.name = name
        apiResponses = [Response]()
    }
    
    func addResponse(response: Response) {
        apiResponses?.append(response)
        println("------------------------------------------------------------------")
        println("Received response:\n\(response)")
        println("------------------------------------------------------------------")
    }
    
    func saveScenario(callback: ((success: Bool, scenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let scenarioFilePath = applicationDocumentsDirectory.absoluteString?.stringByAppendingPathComponent("\(name).scenario")
        let escapedString = scenarioFilePath?.stringByReplacingOccurrencesOfString(" ", withString: "-")
        let scenarioFileURL = NSURL(string: escapedString!)
        if let urlToWrite = scenarioFileURL {
            if NSFileManager.defaultManager().fileExistsAtPath(scenarioFilePath!) {
                NSFileManager.defaultManager().removeItemAtURL(urlToWrite, error: nil)
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(self)
            let success = data.writeToURL(urlToWrite, atomically: true)
            if success {
                println("------------------------------------------------------------------")
                println("Saved\(self) \nFile: \(escapedString!)")
                println("------------------------------------------------------------------\n")
                callback?(success: true, scenario: self)
            } else {
                errorHandler!(error: NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as! String
        apiResponses = aDecoder.decodeObjectForKey("responses") as? [Response]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(apiResponses, forKey: "responses")
    }
    
}

// MARK: Helper methods for debugging
extension Scenario: DebugPrintable, Printable {
    override var description: String { return " Scenario: \(name)"}
    override var debugDescription: String { return " Scenario: \(name)\n Responses: \(apiResponses)\n"}
}
