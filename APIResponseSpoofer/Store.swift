//
//  Store.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/2/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class Store {
    
     class func applicationDocumentsDirectory() -> String {
        // The directory in the application's documents directory used to store the Scenario files.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectoryURL = urls[urls.count-1] as! NSURL
        let documentsDirectoryString = documentsDirectoryURL.absoluteString
        return documentsDirectoryString!
    }

    class func saveScenario(scenario: Scenario, callback: ((success: Bool, savedScenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let documentsDirectory = applicationDocumentsDirectory()
        let scenarioFilePath = ("\(documentsDirectory)\(scenario.name).scenario")
        let escapedString = scenarioFilePath.stringByReplacingOccurrencesOfString(" ", withString: "-")
        let scenarioFileURL = NSURL(string: escapedString)
        if let urlToWrite = scenarioFileURL {
            if NSFileManager.defaultManager().fileExistsAtPath(scenarioFilePath) {
                NSFileManager.defaultManager().removeItemAtURL(urlToWrite, error: nil)
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(scenario)
            let success = data.writeToURL(urlToWrite, atomically: true)
            if success {
                println("-----------------------------------------------------------------------------------------------")
                println("Saved\(scenario) \nFile: \(escapedString)")
                println("-----------------------------------------------------------------------------------------------\n")
                callback?(success: true, savedScenario: scenario)
            } else {
                errorHandler!(error: NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }
    
}