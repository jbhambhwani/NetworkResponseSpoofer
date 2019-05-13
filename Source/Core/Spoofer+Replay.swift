//
//  Spoofer+Replay.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import os

public extension Spoofer {
    // MARK: - Replay

    /// Returns true if the Spoofer is replaying a scenario
    class var isReplaying: Bool {
        return sharedInstance.stateManager.state.isReplaying
    }

    /**
     Starts replaying a recorded scenario

     - parameter name: The name of the scenario to start replay.

     - parameter suite: The name of the scenario to start replay.

     - Precondition: A suite containing the scenario with the specified name must exist on the Spoofer Documents folder of the app

     - Returns: True if replay was started, else false
     */
    @discardableResult class func startReplaying(scenarioName name: String,
                                                 inSuite suite: String = defaultSuiteName) -> Bool {
        let protocolRegistered = SpooferReplayer.startIntercept()

        let loadResult = DataStore.load(scenarioName: name, suite: suite)

        switch loadResult {
        case let .success(scenario):
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("Loaded scenario: %s, Suite: %s", log: Log.database, type: .info, scenarioName, suite)
            }

            Spoofer.sharedInstance.stateManager.transformState(networkAction: .replay(scenarioName: scenario.name,
                                                                                      suiteName: suite))

        case .failure:
            return false
        }

        return protocolRegistered
    }

    /**
     Stop replaying the current scenario
     */
    class func stopReplaying() {
        SpooferReplayer.stopIntercept()
        Spoofer.sharedInstance.stateManager.transformState(networkAction: .stopIntercept)
    }
}
