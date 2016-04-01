//
//  Spoofer+Replay.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import UIKit

extension Spoofer {
    
    // MARK: - Public methods
    
    public class var isReplaying: Bool {
        return sharedInstance.replaying
    }
    
    public class func startReplaying(scenarioName name: String?) -> Bool {
        
        guard let name = name else { return false }
        
        let protocolRegistered = NSURLProtocol.registerClass(ReplayingProtocol)
        Store.loadScenario(name, callback: { success, scenario in
            if success {
                setReplaying = true
                spoofedScenario = scenario
                // Inform the delegate that spoofer started replay
                Spoofer.delegate?.spooferDidStartReplaying(name, success: true)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(spooferStartedReplayingNotification, object: sharedInstance)
            }
            }, errorHandler: { error in
                // Inform the delegate that spoofer could not start replay
                Spoofer.delegate?.spooferDidStartReplaying(name, success: false)
                // Post a state change notification for interested parties
                NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedReplayingNotification, object: sharedInstance)
        })
        return protocolRegistered
    }
    
    public class func stopReplaying() {
        NSURLProtocol.unregisterClass(ReplayingProtocol)
        setReplaying = false
        if let scenarioName = spoofedScenario?.name {
            // Inform the delegate that spoofer stopped replay
            Spoofer.delegate?.spooferDidStopReplaying(scenarioName)
            // Post a state change notification for interested parties
            NSNotificationCenter.defaultCenter().postNotificationName(spooferStoppedReplayingNotification, object: sharedInstance)
        }
        spoofedScenario = nil
    }
    
    // MARK: - Invoke Replay UI
    
    public class func showRecordedScenarios(inViewController sourceViewController: UIViewController?) {
        guard let sourceViewController = sourceViewController else { return }
        let scenarioListController = spooferStoryBoard().instantiateViewControllerWithIdentifier(ScenarioListController.identifier)
        sourceViewController.presentViewController(scenarioListController, animated: true, completion: nil)
    }
}
