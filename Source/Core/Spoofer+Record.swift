//
//  Spoofer+Recording.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import os

public extension Spoofer {
    // MARK: - Record

    /// Returns true if the Spoofer is recording a scenario
    class var isRecording: Bool {
        return sharedInstance.stateManager.state.isRecording
    }

    /**
     Start recording a new scenario

     - parameter name: The scenario name under which all responses will be saved

     - parameter suite: The suite under which the scenario will be saved

     - Returns: True if recording was started, False if not
     */
    @discardableResult class func startRecording(scenarioName name: String,
                                                 inSuite suite: String = defaultSuiteName) -> Bool {
        let protocolRegistered = SpooferRecorder.startIntercept()

        if protocolRegistered {
            // Create a fresh scenario based on the named passed in
            let spoofedScenario = Scenario()
            spoofedScenario.name = name
            let saveResult = DataStore.save(scenario: spoofedScenario, suite: suite)

            switch saveResult {
            case let .success(scenario):
                // Transform state to recording
                Spoofer.sharedInstance.stateManager.transformState(networkAction: .record(scenarioName: scenario.name,
                                                                                          suiteName: suite))
                if #available(iOS 12.0, OSX 10.14, *) {
                    os_log("Started Recording", log: .database)
                }

            case .failure:
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
        if #available(iOS 12.0, OSX 10.14, *) {
            os_log("Stopped Recording", log: .database)
        }
    }
}
