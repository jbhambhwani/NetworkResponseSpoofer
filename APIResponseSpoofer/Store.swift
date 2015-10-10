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
        let scenarioFilePath = getScenarioFilePath(scenario.name)
        if NSFileManager.defaultManager().fileExistsAtPath(scenarioFilePath) {
            do {
                // TODO: Ask if the scenario should be overwritten maybe instead of overwriting blindly
                try NSFileManager.defaultManager().removeItemAtPath(scenarioFilePath)
            } catch _ {
            }
        }
        let data = NSKeyedArchiver.archivedDataWithRootObject(scenario)
        let success = data.writeToFile(scenarioFilePath, atomically: true)
        if success {
            print("-----------------------------------------------------------------------------------------------")
            print("Saved\(scenario) \nFile: \(scenarioFilePath)")
            print("-----------------------------------------------------------------------------------------------\n")
            callback?(success: true, savedScenario: scenario)
        } else {
            let infoDict = ["Unable to save scenario": NSLocalizedFailureReasonErrorKey]
            let spooferError = NSError(domain: "APIResponseSpoofer", code: 500, userInfo: infoDict)
            errorHandler!(error: spooferError)
        }
    }
    
    // Load a scenario from disk
    class func loadScenario(scenarioName: String, callback: ((success: Bool, scenario: Scenario?) -> ())?, errorHandler: ((error: NSError) -> Void)?) {
        let scenarioFilePath = getScenarioFilePath(scenarioName)
        if NSFileManager.defaultManager().fileExistsAtPath(scenarioFilePath) {
            if let scenarioData = NSFileManager.defaultManager().contentsAtPath(scenarioFilePath) {
                let scenario = NSKeyedUnarchiver.unarchiveObjectWithData(scenarioData) as? Scenario
                callback?(success: true, scenario: scenario)
                print("-----------------------------------------------------------------------------------------------")
                print("Loaded\(scenario!) \nFile: \(scenarioFilePath)")
                print("-----------------------------------------------------------------------------------------------\n")
            }
        } else {
            let infoDict = ["Unable to load scenario": NSLocalizedFailureReasonErrorKey]
            let spooferError = NSError(domain: "APIResponseSpoofer", code: 500, userInfo: infoDict)
            errorHandler!(error: spooferError)
        }
    }

    // Retrieve all scenarios from disk
    class func allScenarios() -> [Scenario]? {
        
        var allFiles:[NSURL]
        do {
            try allFiles = NSFileManager.defaultManager().contentsOfDirectoryAtURL(spooferDocumentsDirectory(), includingPropertiesForKeys: [], options: .SkipsSubdirectoryDescendants)
        } catch {
            return nil
        }
        
        let scenarioFiles:[NSString] = allFiles.map{ $0.lastPathComponent! }.filter{ $0.pathExtension == "scenario"}
        
        if scenarioFiles.isEmpty {
            return nil
        } else {
            var cachedScenarios = [Scenario]()
            for oneFile in scenarioFiles {
                let scenarioFielPath = getScenarioFilePath(oneFile.stringByDeletingPathExtension)
                if let scenarioData = NSFileManager.defaultManager().contentsAtPath(scenarioFielPath) {
                    let scenario = NSKeyedUnarchiver.unarchiveObjectWithData(scenarioData) as? Scenario
                    cachedScenarios.append(scenario!)
                }
            }
            return cachedScenarios
        }
    }
    
    // MARK: Private methods
    private class func getScenarioFilePath(scenarioName: String) -> String {
        // Get a reference to the documents directory
        let spooferDirectory = applicationDocumentsDirectory()
        // Construct a file name based on the scenario file
        let scenarioFilePath = ("\(spooferDirectory)/\(scenarioName).scenario")
        let escapedString = scenarioFilePath.stringByReplacingOccurrencesOfString(" ", withString: "-")
        return escapedString
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
    
    // TODO: Currently not creating the folder "Spoofer". Need to debug
    private class func spooferDocumentsDirectory() -> NSURL {
        let spooferDirectoryURL = applicationDocumentsDirectory().URLByAppendingPathComponent("Spoofer")
        var isDir = ObjCBool(true)
        if !NSFileManager.defaultManager().fileExistsAtPath(spooferDirectoryURL.absoluteString, isDirectory: &isDir) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(spooferDirectoryURL.absoluteString, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
        }
        return spooferDirectoryURL
    }
    
}