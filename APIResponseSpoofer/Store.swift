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
        
        guard scenario.apiResponses.count > 0 else {
            handleError("Scenario was empty and hence not saved", recoveryMessage: "No responses were recorded. Make one or more HTTP requests and try saving again", code: SpooferError.EmptyScenarioError.rawValue, errorHandler: errorHandler)
            return
        }
        
        let scenarioFileURL = getScenarioFileURL(scenario.name)
        if NSFileManager.defaultManager().fileExistsAtPath(scenarioFileURL.absoluteString) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(scenarioFileURL)
            } catch {
                
            }
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(scenario)
        let success = data.writeToURL(scenarioFileURL, atomically: true)
        if success {
            logFormattedSeperator()
            postNotification("Saved \(scenario)\nFile: \(scenarioFileURL)", object: self)
            callback?(success: true, savedScenario: scenario)
        } else {
            handleError("Unable to save scenario", recoveryMessage: "Writing to disk failed. Try again", code: SpooferError.DiskWriteError.rawValue, errorHandler: errorHandler)
        }
    }
    
    // Load a scenario from disk
    class func loadScenario(scenarioName: String, callback: ((success: Bool, scenario: Scenario) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let scenarioFileURL = getScenarioFileURL(scenarioName)
        var scenarioData: NSData?
        do {
            try scenarioData = NSData(contentsOfURL: scenarioFileURL, options: .DataReadingMappedIfSafe)
        } catch {
            handleError("Error reading from file: \(scenarioFileURL)", recoveryMessage: "Reading from disk failed. Try again", code: SpooferError.DiskReadError.rawValue, errorHandler: errorHandler)
        }
        if let unwrappedData = scenarioData where unwrappedData.length > 0 {
            let scenario = NSKeyedUnarchiver.unarchiveObjectWithData(unwrappedData) as? Scenario
            if let unwrappedScenario = scenario {
                callback?(success: true, scenario: unwrappedScenario)
                postNotification("Loaded \(scenario!)\nFile: \(scenarioFileURL)", object: self)
                logFormattedSeperator()
            }
        } else {
            handleError("Empty scenario file found at: \(scenarioFileURL)", recoveryMessage: "Remove the file or re-record the scenario.", code: SpooferError.EmptyFileError.rawValue, errorHandler: errorHandler)
        }
    }

    // Retrieve all scenarios from disk
    class func allScenarioNames() -> [String] {
        var allFiles:[NSURL]
        do {
            try allFiles = NSFileManager.defaultManager().contentsOfDirectoryAtURL(spooferDocumentsDirectory(), includingPropertiesForKeys: [], options: .SkipsSubdirectoryDescendants)
        } catch {
            return [String]()
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