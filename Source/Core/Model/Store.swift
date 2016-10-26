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
    class func saveScenario(_ scenario: Scenario, callback: ((_ success: Bool, _ savedScenario: Scenario?) -> ())?, errorHandler: ((_ error: NSError) -> Void)?) {
        
        guard scenario.apiResponses.count > 0 else {
            handleError("Scenario was empty and hence not saved", recoveryMessage: "No responses were recorded. Make one or more HTTP requests and try saving again", code: SpooferError.emptyScenarioError.rawValue, errorHandler: errorHandler)
            return
        }
        
        guard let scenarioFileURL = getScenarioFileURL(scenario.name) else {
            handleError("Unable to save scenario", recoveryMessage: "URL could not be created for scenario name", code: SpooferError.scenarioURLError.rawValue, errorHandler: errorHandler)
            return
        }
        
        let urlPath = scenarioFileURL.absoluteString
        
        if FileManager.default.fileExists(atPath: urlPath) {
            do {
                try FileManager.default.removeItem(at: scenarioFileURL)
            } catch {
                
            }
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: scenario)
        let success = (try? data.write(to: scenarioFileURL, options: [])) != nil
        if success {
            logFormattedSeperator()
            postNotification("Saved \(scenario)\nFile: \(scenarioFileURL)", object: self)
            callback?(true, scenario)
        } else {
            handleError("Unable to save scenario", recoveryMessage: "Writing to disk failed. Try again", code: SpooferError.diskWriteError.rawValue, errorHandler: errorHandler)
        }
    }
    
    // Load a scenario from disk
    class func loadScenario(_ scenarioName: String, callback: ((_ success: Bool, _ scenario: Scenario) -> ())?, errorHandler: ((_ error: NSError) -> Void)?) {
        
        guard let scenarioFileURL = getScenarioFileURL(scenarioName) else {
            handleError("Unable to save scenario", recoveryMessage: "URL could not be created for scenario name", code: SpooferError.scenarioURLError.rawValue, errorHandler: errorHandler)
            return
        }
        
        var scenarioData: Data?
        do {
            try scenarioData = Data(contentsOf: scenarioFileURL, options: .mappedIfSafe)
        } catch {
            handleError("Error reading from file: \(scenarioFileURL)", recoveryMessage: "Reading from disk failed. Try again", code: SpooferError.diskReadError.rawValue, errorHandler: errorHandler)
        }
        if let unwrappedData = scenarioData, unwrappedData.count > 0 {
            let scenario = NSKeyedUnarchiver.unarchiveObject(with: unwrappedData) as? Scenario
            if let unwrappedScenario = scenario {
                callback?(true, unwrappedScenario)
                postNotification("Loaded \(unwrappedScenario)\nFile: \(scenarioFileURL)", object: self)
                logFormattedSeperator()
            }
        } else {
            handleError("Empty scenario file found at: \(scenarioFileURL)", recoveryMessage: "Remove the file or re-record the scenario.", code: SpooferError.emptyFileError.rawValue, errorHandler: errorHandler)
        }
    }

    // Delete a scenario
    class func deleteScenario(_ scenarioName: String, callback: ((_ success: Bool) -> ())?, errorHandler: ((_ error: NSError) -> Void)?) {
        
        let scenarioFileURL = getScenarioFileURL(scenarioName)
        
        if deleteScenario(scenarioName) {
            callback?(true)
        } else {
            handleError("Unable to delete scenario at: \(scenarioFileURL)", recoveryMessage: "Retry again later", code: SpooferError.scenarioDeletionError.rawValue, errorHandler: errorHandler)
        }
    }
    
    // Retrieve all scenarios from disk
    class func allScenarioNames() -> [String] {
        
        guard let docsDir = spooferDocumentsDirectory() else { return [] }
        
        var allFiles: [URL]
        do {
            try allFiles = FileManager.default.contentsOfDirectory(at: docsDir, includingPropertiesForKeys: [], options: .skipsSubdirectoryDescendants)
        } catch {
            return []
        }
        
        let fileNames = allFiles.filter { $0.lastPathComponent.hasSuffix("scenario") }.flatMap { $0.deletingPathExtension().lastPathComponent }
        return fileNames
    }
    
    // MARK: - Private methods
    
    private class func getScenarioFileURL(_ scenarioName: String) -> URL? {
        
        guard let docsDir = spooferDocumentsDirectory() else { return nil }
        
        // Get a reference to the documents directory & Construct a file name based on the scenario file
        let scenarioFileURL =  docsDir.appendingPathComponent("\(scenarioName).scenario")
        return scenarioFileURL
    }

    private class func deleteScenario(_ scenarioName: String) -> Bool {
        
        // Get a reference to the documents directory & Construct a file name based on the scenario file
        guard let scenarioFileURL = getScenarioFileURL(scenarioName) else { return false }
        do {
            try FileManager.default.removeItem(at: scenarioFileURL)
            return true
        } catch {
            return false
        }
    }
    
    private class func applicationDocumentsDirectory() -> URL? {
        
        // The directory in the application's documents directory used to store the Scenario files.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentsDirectoryURL = urls.first else {
            print("Documents directory was not available")
            return nil
        }
        return documentsDirectoryURL
    }
    
    private class func spooferDocumentsDirectory() -> URL? {
        
        guard let spooferDirectoryURL = applicationDocumentsDirectory()?.appendingPathComponent("Spoofer") else { return nil }
        
        let spooferDirectoryURLString = spooferDirectoryURL.absoluteString
        var isDir = ObjCBool(true)
        
        guard FileManager.default.fileExists(atPath: spooferDirectoryURLString, isDirectory: &isDir) == false else { return nil }
        
        do {
            try FileManager.default.createDirectory(at: spooferDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch _ {
            print("Spoofer directory creation failed!")
            return nil
        }
        
        return spooferDirectoryURL
    }
    
}
