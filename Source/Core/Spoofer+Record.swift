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
        return sharedInstance.stateManager.state.isRecording
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
            // Create a fresh scenario based on the named passed in
            let spoofedScenario = ScenarioV2()
            spoofedScenario.name = name
            let saveResult = DataStore.save(scenario: spoofedScenario)
            
            switch saveResult {
            case .success(let scenario):
                // Transform state to recording
                Spoofer.sharedInstance.stateManager.transformState(networkAction: .record(scenarioName: scenario.name))
                
            case .failure(_):
                return false
            }
        }
        
        return protocolRegistered
    }
    
    /**
     Stop recording the current scenario
     */
    class func stopRecording() {

        SpooferRecorder.stopIntercept()

        let success = scenarioName.isEmpty == false
        // Post a notification and Inform the delegate
        NotificationCenter.default.post(name:
            Notification.Name(rawValue: spooferStoppedRecordingNotification),
                                        object: sharedInstance,
                                        userInfo: ["scenario": scenarioName, "success": success])
        Spoofer.delegate?.spooferDidStopRecording(scenarioName)
    }
    
}
