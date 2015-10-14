//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

// MARK: Public Enums
public enum SpooferError: Int, ErrorType {
    case DiskReadError = 500
    case DiskWriteError = 501
    case EmptyFileError = 502
    case DocumentsAccessError = 503
    case FolderCreationError = 504
    case EmptyScenarioError = 505
    case NoSavedResponseError = 506
}

public class Spoofer {
    
    // MARK: - Internal variables
    private static let sharedInstance = Spoofer()
    private var scenario: Scenario? = nil
    private var recording: Bool = false
    private var replaying: Bool = false
    private var spoofedDomains = [String]()
    private var ignoredQueryParameters = [String]()
    
    // MARK: - Public properties
    public class var domainsToSpoof:[String] {
        get {
        return self.sharedInstance.spoofedDomains
        }
        set {
            self.sharedInstance.spoofedDomains = newValue
        }
    }
    
    public class var queryParametersToIgnore:[String] {
        get {
        return self.sharedInstance.ignoredQueryParameters
        }
        set {
            self.sharedInstance.ignoredQueryParameters = newValue
        }
    }
    
    // MARK: - Public methods
    public class func startRecording(scenarioName scenarioName: String) -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(RecordingProtocol)
        if protocolRegistered {
            self.setRecording = true
            // Create a fresh scenario based on the named passed in
            // TODO: Check if scenario exists and ask the user if to overwrite
            self.spoofedScenario = Scenario(name: scenarioName)
        }
        return protocolRegistered
    }
    
    public class func stopRecording() {
        NSURLProtocol.unregisterClass(RecordingProtocol)
        Store.saveScenario(self.sharedInstance.scenario!, callback: { success, savedScenario in
            self.setRecording = false
            self.spoofedScenario = nil
            }, errorHandler: { error in
                self.setRecording = false
                self.spoofedScenario = nil
                // TODO: Let know the user that the scenario could not be saved
        })
    }
    
    public class func isRecording() -> Bool {
        return self.sharedInstance.recording
    }
    
    public class func startReplaying(scenarioName scenarioName: String) -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(ReplayingProtocol)
        Store.loadScenario(scenarioName, callback: { success, scenario in
            if success {
                self.setReplaying = true
                self.spoofedScenario = scenario
            }
            }, errorHandler: { error in
                // TODO: Let know the user that the scenario could not be loaded
        })
        return protocolRegistered
    }
    
    public class func stopReplaying() {
        NSURLProtocol.unregisterClass(ReplayingProtocol)
        self.spoofedScenario = nil
        self.setReplaying = false
    }
    
    public class func isReplaying() -> Bool {
        return self.sharedInstance.replaying
    }
    
    public class func showRecordedScenarios(inViewController sourceViewController: UIViewController) {
        let scenarioListController = spooferStoryBoard().instantiateViewControllerWithIdentifier(ScenarioListController.identifier)
        sourceViewController.view.addSubview(scenarioListController.view)
        sourceViewController.presentViewController(scenarioListController, animated: true, completion: nil)
    }
    
    // MARK: Internal methods and properties
    class func shouldHandleURL(url: NSURL) -> Bool {
        if domainsToSpoof.isEmpty {
            // Handle all cases in case no domains are whitelisted
            return true
        } else {
            // If whitelist is set, use it
            for hostDomain in domainsToSpoof {
                if hostDomain == url.host {
                    return true
                }
            }
            return false
        }
    }
    
    class var spoofedScenario: Scenario? {
        get {
        if let unwrappedScenario = Spoofer.sharedInstance.scenario {
        return unwrappedScenario
        }
        return nil
        }
        set(newValue) {
            self.sharedInstance.scenario = newValue
        }
    }
    
    class var setRecording: Bool {
        get {
        return self.sharedInstance.recording
        }
        set(newValue) {
            self.sharedInstance.recording = newValue
            if newValue {
                logFormattedSeperator("Spoofer Recording Started")
            } else {
                logFormattedSeperator("Spoofer Recording Ended")
            }
        }
    }
    
    class var setReplaying: Bool {
        get {
        return self.sharedInstance.replaying
        }
        set(newValue) {
            self.sharedInstance.replaying = newValue
            if newValue {
                logFormattedSeperator("Spoofer Replay Started")
            } else {
                logFormattedSeperator("Spoofer Replay Ended")
            }
        }
    }
    
}
