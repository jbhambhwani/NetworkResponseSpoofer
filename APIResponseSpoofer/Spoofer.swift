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

@objc(Spoofer)

public class Spoofer: NSObject {
    
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
    public class func startRecording(scenarioName scenarioName: String, inViewController sourceViewController: UIViewController? = nil) -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(RecordingProtocol)
        if protocolRegistered {
            // If a view controller was passed in, use it to display an alert controller asking for a scenario name
            if let presentingViewController = sourceViewController {
                let alertController = UIAlertController(title: "Create Scenario", message: "Enter a scenario name to save the requests & responses", preferredStyle: .Alert)
                
                let createAction = UIAlertAction(title: "Create", style: .Default) { (_) in
                    let scenarioNameTextField = alertController.textFields![0] as UITextField
                    startRecording(scenarioName: scenarioNameTextField.text!)
                }
                createAction.enabled = false
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
                    self.setRecording = false
                    self.spoofedScenario = nil
                    NSURLProtocol.unregisterClass(RecordingProtocol)
                }
                
                alertController.addTextFieldWithConfigurationHandler { (textField) in
                    textField.placeholder = "Enter scenario name"
                    NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                        createAction.enabled = textField.text != ""
                    }
                }
                
                alertController.addAction(createAction)
                alertController.addAction(cancelAction)
                
                presentingViewController.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.setRecording = true
                // Create a fresh scenario based on the named passed in
                self.spoofedScenario = Scenario(name: scenarioName)
            }
        }
        return protocolRegistered
    }
    
    public class func stopRecording() {
        NSURLProtocol.unregisterClass(RecordingProtocol)
        guard let scenario = self.sharedInstance.scenario else { return }
        Store.saveScenario(scenario, callback: { success, savedScenario in
            if success {
                self.setRecording = false
                self.spoofedScenario = nil
            }
            }, errorHandler: { error in
                self.setRecording = false
                self.spoofedScenario = nil
                // TODO: Let know the user that the scenario could not be saved
        })
    }
    
    public class var isRecording: Bool {
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
    
    public class var isReplaying: Bool {
        return self.sharedInstance.replaying
    }
    
    // MARK: - Invoke Replay UI
    public class func showRecordedScenarios(inViewController sourceViewController: UIViewController?) {
        guard let sourceViewController = sourceViewController else { return }
        let scenarioListController = spooferStoryBoard().instantiateViewControllerWithIdentifier(ScenarioListController.identifier)
        sourceViewController.view.addSubview(scenarioListController.view)
        sourceViewController.presentViewController(scenarioListController, animated: true, completion: nil)
    }
    
    // MARK: - Internal methods and properties
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
