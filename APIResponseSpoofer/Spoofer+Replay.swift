//
//  Spoofer+Replay.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation

extension Spoofer {
 
    // MARK: - Public methods
    
    public class var isReplaying: Bool {
        return self.sharedInstance.replaying
    }
    
    public class func startReplaying(scenarioName scenarioName: String) -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(ReplayingProtocol)
        Store.loadScenario(scenarioName, callback: { success, scenario in
            if success {
                self.setReplaying = true
                self.spoofedScenario = scenario
                // Inform the delegate that spoofer started replay
                Spoofer.delegate?.spooferDidStartReplaying(scenarioName, success: true)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(SpooferStartedReplayingNotification, object: sharedInstance)
            }
            }, errorHandler: { error in
                // Inform the delegate that spoofer could not start replay
                Spoofer.delegate?.spooferDidStartReplaying(scenarioName, success: false)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(SpooferStoppedReplayingNotification, object: sharedInstance)
        })
        return protocolRegistered
    }
    
    public class func stopReplaying() {
        NSURLProtocol.unregisterClass(ReplayingProtocol)
        if let scenarioName = self.spoofedScenario?.name {
            // Inform the delegate that spoofer stopped replay
            Spoofer.delegate?.spooferDidStopReplaying(scenarioName)
            // Post a state change notification for interested parties
            NSNotificationCenter.defaultCenter().postNotificationName(SpooferStoppedReplayingNotification, object: sharedInstance)
        }
        self.spoofedScenario = nil
        self.setReplaying = false
    }
    
    // MARK: - Invoke Replay UI
    public class func showRecordedScenarios(inViewController sourceViewController: UIViewController?) {
        guard let sourceViewController = sourceViewController else { return }
        let scenarioListController = spooferStoryBoard().instantiateViewControllerWithIdentifier(ScenarioListController.identifier)
        sourceViewController.view.addSubview(scenarioListController.view)
        sourceViewController.presentViewController(scenarioListController, animated: true, completion: nil)
    }
    
}