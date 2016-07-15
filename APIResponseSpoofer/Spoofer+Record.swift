//
//  Spoofer+Recording.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import UIKit

public extension Spoofer {

    // MARK: - Record
    
    /// Returns true if the Spoofer is recording a scenario
    class var isRecording: Bool {
        return sharedInstance.recording
    }
    
    /**
     Starts recording a new scenario from a specific view controller.
     
     - parameter sourceViewController: The view controller from which the record popup UI will be presented from
     
     - Note: A popup will appear asking the user to name the scenario, before recording starts. Use this method if you need to manually provide the scenario name
     */
    class func startRecording(inViewController sourceViewController: UIViewController?) {
        
        guard let sourceViewController = sourceViewController else { return }
        
        // When a view controller was passed in, use it to display an alert controller asking for a scenario name
        let alertController = UIAlertController(title: "Create Scenario", message: "Enter a scenario name to save the requests & responses", preferredStyle: .Alert)
        
        let createAction = UIAlertAction(title: "Create", style: .Default) { [unowned alertController](_) in
            if let textField = alertController.textFields?.first, scenarioName = textField.text {
                startRecording(scenarioName: scenarioName)
            }
        }
        createAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            setRecording = false
            spoofedScenario = nil
            RecordingProtocol.stopIntercept()
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter scenario name"
            textField.autocapitalizationType = .Sentences
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                createAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        sourceViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     Start recording a new scenario
     
     - parameter name: The scenario name under which all responses will be saved
     
     - Returns: True if recording was started, False if not
     */
    class func startRecording(scenarioName name: String?) -> Bool {
        
        guard let name = name else { return false }
        
        let protocolRegistered = RecordingProtocol.startIntercept()
        
        if protocolRegistered {
            setRecording = true
            // Create a fresh scenario based on the named passed in
            spoofedScenario = Scenario(name: name)
            // Inform the delegate that spoofer started recording
            Spoofer.delegate?.spooferDidStartRecording(name)
            // Post a state change notification for interested parties
            NSNotificationCenter.defaultCenter().postNotificationName(spooferStartedRecordingNotification, object: sharedInstance, userInfo: ["scenario": name])
        }
        
        return protocolRegistered
    }
    
    /**
     Stop recording the current scenario and save the .scenario file to Documents folder
     */
    class func stopRecording() {
        RecordingProtocol.stopIntercept()
        guard let scenario = sharedInstance.scenario else { return }
        Store.saveScenario(scenario, callback: { success, savedScenario in
            if success {
                setRecording = false
                spoofedScenario = nil
                guard let savedScenario = savedScenario else { return }
                // Inform the delegate of successful save
                Spoofer.delegate?.spooferDidStopRecording(savedScenario.name, success: true)
                NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedRecordingNotification, object: sharedInstance, userInfo: ["scenario": savedScenario.name, "success": true])
            }
            }, errorHandler: { error in
                if let scenarioName = spoofedScenario?.name {
                    setRecording = false
                    spoofedScenario = nil
                    // Inform the delegate that saving scenario failed
                    Spoofer.delegate?.spooferDidStopRecording(scenarioName, success: false)
                    // Post a state change notification for interested parties
                    NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedRecordingNotification, object: sharedInstance, userInfo: ["scenario": scenarioName])
                }
        })
    }
    
}
