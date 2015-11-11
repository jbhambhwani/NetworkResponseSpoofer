//
//  Spoofer+Recording.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation

extension Spoofer {
    
    // MARK: - Public methods
    
    public class var isRecording: Bool {
        return self.sharedInstance.recording
    }
    
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
                // Inform the delegate that spoofer started recording
                Spoofer.delegate?.spooferDidStartRecording(scenarioName)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(SpooferStartedRecordingNotification, object: sharedInstance)
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
                // Inform the delegate of successful save
                Spoofer.delegate?.spooferDidStopRecording(savedScenario!.name, success: true)
                NSNotificationCenter.defaultCenter().postNotificationName(SpooferStoppedRecordingNotification, object: sharedInstance)
            }
            }, errorHandler: { error in
                if let scenarioName = self.spoofedScenario?.name {
                    // Inform the delegate that saving scenario failed
                    Spoofer.delegate?.spooferDidStopRecording(scenarioName, success: false)
                    // Post a state change notification for interested parties
                    NSNotificationCenter.defaultCenter().postNotificationName(SpooferStoppedRecordingNotification, object: sharedInstance)
                    self.setRecording = false
                    self.spoofedScenario = nil
                }
        })
    }
    
}