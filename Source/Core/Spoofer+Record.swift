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
        let alertController = UIAlertController(title: "Create Scenario", message: "Enter a scenario name to save the requests & responses", preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [unowned alertController](_) in
            if let textField = alertController.textFields?.first, let scenarioName = textField.text {
                _ = startRecording(scenarioName: scenarioName)
            }
        }
        createAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            setRecording = false
            spoofedScenario = nil
            SpooferRecorder.stopIntercept()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter scenario name"
            textField.autocapitalizationType = .sentences
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                createAction.isEnabled = textField.text != ""
            }
        }
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        sourceViewController.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Start recording a new scenario
     
     - parameter name: The scenario name under which all responses will be saved
     
     - Returns: True if recording was started, False if not
     */
    @discardableResult class func startRecording(scenarioName name: String?) -> Bool {
        
        guard let name = name else { return false }
        
        let protocolRegistered = SpooferRecorder.startIntercept()
        
        if protocolRegistered {
            setRecording = true
            // Create a fresh scenario based on the named passed in
            spoofedScenario = ScenarioV2()
            spoofedScenario?.name = name
            // Inform the delegate that spoofer started recording
            Spoofer.delegate?.spooferDidStartRecording(name)
            // Post a state change notification for interested parties
            NotificationCenter.default.post(name: Notification.Name(rawValue: spooferStartedRecordingNotification), object: sharedInstance, userInfo: ["scenario": name])
        }
        
        return protocolRegistered
    }
    
    /**
     Stop recording the current scenario and save the .scenario file to Documents folder
     */
    class func stopRecording() {
        SpooferRecorder.stopIntercept()
        guard let scenario = sharedInstance.scenario else { return }
        
        let saveResult = DataStore.save(scenario: scenario)
        
        switch saveResult {
        case .success(let savedScenario):
            setRecording = false
            spoofedScenario = nil
            // Inform the delegate of successful save
            Spoofer.delegate?.spooferDidStopRecording(savedScenario.name, success: true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: spooferStoppedRecordingNotification), object: sharedInstance, userInfo: ["scenario": savedScenario.name, "success": true])
            
        case .failure(_):
            if let scenarioName = spoofedScenario?.name {
                setRecording = false
                spoofedScenario = nil
                // Inform the delegate that saving scenario failed
                Spoofer.delegate?.spooferDidStopRecording(scenarioName, success: false)
                // Post a state change notification for interested parties
                NotificationCenter.default.post(name: Notification.Name(rawValue: spooferStoppedRecordingNotification), object: sharedInstance, userInfo: ["scenario": scenarioName])
            }
        }
    }
    
}
