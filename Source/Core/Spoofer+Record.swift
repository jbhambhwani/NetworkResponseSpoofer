//
//  Spoofer+Recording.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation

public extension Spoofer {

    // MARK: - Record
    
    /// Returns true if the Spoofer is recording a scenario
    class var isRecording: Bool {
        return sharedInstance.stateManager.state.isRecording
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
            let spoofedScenario = Scenario()
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
        Spoofer.sharedInstance.stateManager.transformState(networkAction: .stopIntercept)
    }
    
}
