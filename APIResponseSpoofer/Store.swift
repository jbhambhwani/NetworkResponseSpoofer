//
//  Store.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/2/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class Store {
    
    class func saveScenario(scenario: Scenario, callback: ((success: Bool, savedScenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let scenarioFilePath = getScenarioFilePath(scenario.name)
        let scenarioFileURL = NSURL(string: scenarioFilePath)
        if let urlToWrite = scenarioFileURL {
            if NSFileManager.defaultManager().fileExistsAtPath(scenarioFilePath) {
                // TODO: Ask if the scenario should be overwritten maybe instead of overwriting blindly
                NSFileManager.defaultManager().removeItemAtURL(urlToWrite, error: nil)
            }
            let data = NSKeyedArchiver.archivedDataWithRootObject(scenario)
            let success = data.writeToURL(urlToWrite, atomically: true)
            if success {
                println("-----------------------------------------------------------------------------------------------")
                println("Saved\(scenario) \nFile: \(scenarioFilePath)")
                println("-----------------------------------------------------------------------------------------------\n")
                callback?(success: true, savedScenario: scenario)
            } else {
                errorHandler!(error: NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }

    class func loadScenario(scenarioName: String, callback: ((success: Bool, scenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let scenarioFilePath = getScenarioFilePath(scenarioName)
        if NSFileManager.defaultManager().fileExistsAtPath(scenarioFilePath) {
            if let scenarioData = NSFileManager.defaultManager().contentsAtPath(scenarioFilePath) {
                let scenario = NSKeyedUnarchiver.unarchiveObjectWithData(scenarioData) as? Scenario
                callback?(success: true, scenario: scenario)
                println("-----------------------------------------------------------------------------------------------")
                println("Loaded\(scenario) \nFile: \(scenarioFilePath)")
                println("-----------------------------------------------------------------------------------------------\n")
            }
        } else {
            // TODO: Let the user know the scenario could not be loaded
            errorHandler!(error: NSError(domain: "", code: 0, userInfo: nil))
        }
    }

    private class func getScenarioFilePath(scenarioName: String) -> String {
        // Get a reference to the documents directory
        let spooferDirectory = applicationDocumentsDirectory()
        // Construct a file name based on the scenario file
        let scenarioFilePath = ("\(spooferDirectory)\(scenarioName).scenario")
        let escapedString = scenarioFilePath.stringByReplacingOccurrencesOfString(" ", withString: "-")
        return escapedString
    }
    
    private class func applicationDocumentsDirectory() -> String {
        // The directory in the application's documents directory used to store the Scenario files.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectoryURL = urls[urls.count-1] as! NSURL
        let documentsDirectoryString = documentsDirectoryURL.absoluteString
        return documentsDirectoryString!
    }
    
    // TODO: Currently not creating the folder. Need to debug
    private class func spooferDocumentsDirectory() -> String {
        let documentsDirectory = applicationDocumentsDirectory()
        let spooferFolder = documentsDirectory.stringByAppendingPathComponent("Spoofer")
        var isDir = ObjCBool(true)
        if !NSFileManager.defaultManager().fileExistsAtPath(spooferFolder, isDirectory: &isDir) {
            NSFileManager.defaultManager().createDirectoryAtPath(spooferFolder, withIntermediateDirectories: false, attributes: nil, error: nil)
        }
        return spooferFolder
    }
    
}