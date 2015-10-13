//
//  Store.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/2/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class Store {
    
    // Save a scenario to disk
    class func saveScenario(scenario: Scenario, callback: ((success: Bool, savedScenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        
//        guard scenario.apiResponses.count > 0 else {
//            
//        }
        
        let scenarioFileURL = getScenarioFileURL(scenario.name)
        if NSFileManager.defaultManager().fileExistsAtPath(scenarioFileURL.absoluteString) {
            do {
                // TODO: Ask if the scenario should be overwritten maybe instead of overwriting blindly
                try NSFileManager.defaultManager().removeItemAtURL(scenarioFileURL)
            } catch {
                
            }
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(scenario)
        let success = data.writeToURL(scenarioFileURL, atomically: true)
        if success {
            logFormattedSeperator()
            print("Saved\(scenario) \nFile: \(scenarioFileURL)")
            callback?(success: true, savedScenario: scenario)
        } else {
            let infoDict = ["Unable to save scenario": NSLocalizedFailureReasonErrorKey]
            let spooferError = NSError(domain: "APIResponseSpoofer", code: 500, userInfo: infoDict)
            errorHandler?(error: spooferError)
        }
    }
    
    // Load a scenario from disk
    class func loadScenario(scenarioName: String, callback: ((success: Bool, scenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let scenarioFileURL = getScenarioFileURL(scenarioName)
        var scenarioData: NSData?
        do {
            try scenarioData = NSData(contentsOfURL: scenarioFileURL, options: .DataReadingMappedIfSafe)
        } catch {
            let infoDict = ["Error Reading from File: \(scenarioFileURL)": NSLocalizedFailureReasonErrorKey]
            let spooferError = NSError(domain: "APIResponseSpoofer", code: 500, userInfo: infoDict)
            errorHandler?(error: spooferError)
        }
        if let unwrappedData = scenarioData where unwrappedData.length > 0 {
            let scenario = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedData) as? Scenario
            callback?(success: true, scenario: scenario)
            print("Loaded\(scenario!) \nFile: \(scenarioFileURL)")
            logFormattedSeperator()
        } else {
            let infoDict = ["Empty Scenario File: \(scenarioFileURL)": NSLocalizedFailureReasonErrorKey]
            let spooferError = NSError(domain: "APIResponseSpoofer", code: 501, userInfo: infoDict)
            errorHandler?(error: spooferError)
        }
    }

    // Retrieve all scenarios from disk
    class func allScenarioNames() -> [NSString] {
        var allFiles:[NSURL]
        do {
            try allFiles = NSFileManager.defaultManager().contentsOfDirectoryAtURL(spooferDocumentsDirectory(), includingPropertiesForKeys: [], options: .SkipsSubdirectoryDescendants)
        } catch {
            return [NSString]()
        }
        
        let scenarioFiles:[NSString] = allFiles.map{ $0.lastPathComponent! }.filter{ $0.pathExtension == "scenario"}
        let fileNames = scenarioFiles.map{ $0.stringByDeletingPathExtension }
        return fileNames
    }
    
    // MARK: Private methods
    private class func getScenarioFileURL(scenarioName: String) -> NSURL {
        // Get a reference to the documents directory & Construct a file name based on the scenario file
        let scenarioFileURL = spooferDocumentsDirectory().URLByAppendingPathComponent("\(scenarioName).scenario")
        return scenarioFileURL
        // let escapedString = scenarioFilePath.absoluteString.stringByReplacingOccurrencesOfString(" ", withString: "-")
        // return escapedString
    }
    
    private class func applicationDocumentsDirectory() -> NSURL {
        // The directory in the application's documents directory used to store the Scenario files.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        guard let documentsDirectoryURL:NSURL = urls.first else {
            print("Documents directory was not available")
            return NSURL()
        }
        return documentsDirectoryURL
    }
    
    private class func spooferDocumentsDirectory() -> NSURL {
        let spooferDirectoryURL = applicationDocumentsDirectory().URLByAppendingPathComponent("Spoofer")
        var isDir = ObjCBool(true)
        if !NSFileManager.defaultManager().fileExistsAtPath(spooferDirectoryURL.absoluteString, isDirectory: &isDir) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(spooferDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
                print("Spoofer directory creation failed!")
            }
        }
        return spooferDirectoryURL
    }
    
}