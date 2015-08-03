//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

@objc public class Spoofer {
    
    // MARK: Internal variables
    private static let sharedInstance = Spoofer()
    private var scenario: Scenario? = nil
    private var recording: Bool = false
    private var replaying: Bool = false
    private var spoofedDomains = [String]()
    
    // MARK: Public properties
    public class var domainsToSpoof:[String] {
        get {
            return self.sharedInstance.spoofedDomains
        }
        set {
            self.sharedInstance.spoofedDomains = newValue
        }
    }
    
    // MARK: Public methods
    public class func startRecording(#scenarioName: String) -> Bool {
        let protocolRegistered = NSURLProtocol.registerClass(RecordingProtocol)
        if protocolRegistered {
            self.setRecording = true
            // Create a fresh scenario based on the named passed in
            // TODO: Check if scenario exists and ask the user if to overwrite
            self.spoofedScenario = Scenario(name: scenarioName)
        }
        return protocolRegistered
    }
    
    public class func stopRecording() {
        NSURLProtocol.unregisterClass(RecordingProtocol)
        Store.saveScenario(self.sharedInstance.scenario!, callback: { success, savedScenario in
            self.setRecording = false
            self.spoofedScenario = nil
            }, errorHandler: { error in
                // TODO: Let know the user that the scenario could not be saved
        })
    }
    
    public class func isRecording() -> Bool {
        return self.sharedInstance.recording
    }
    
    public class func startReplaying(#scenarioName: String) -> Bool {
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
    
    public class func isReplaying() -> Bool {
        return self.sharedInstance.replaying
    }
    
    // MARK: Internal methods and properties
    class func shouldHandleURL(url: NSURL) -> Bool {
        // If whitelist is set, use it
        if domainsToSpoof.count > 0 {
            for (index, hostDomain) in enumerate(domainsToSpoof) {
                if hostDomain == url.host {
                    return true
                }
            }
            return false
        } else {
            // Handle all cases in case no domains are requested for
            return true
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
                println("-----------------------------------Spoofer Recording Started-----------------------------------")
            } else {
                println("------------------------------------Spoofer Recording Ended------------------------------------")
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
                println("------------------------------------Spoofer Replay Started-------------------------------------")
            } else {
                println("-------------------------------------Spoofer Replay Ended--------------------------------------")
            }
        }
    }

}
