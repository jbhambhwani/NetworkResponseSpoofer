//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

// MARK: Public Enums
public enum SpooferError: Int, ErrorType {
    case DiskReadError = 500
    case DiskWriteError = 501
    case EmptyFileError = 502
    case DocumentsAccessError = 503
    case FolderCreationError = 504
    case EmptyScenarioError = 505
    case NoSavedResponseError = 506
}

@objc public protocol SpooferDelegate {
    func spooferDidStartRecording(scenarioName: String)
    func spooferDidStopRecording(scenarioName: String, success: Bool)
    func spooferDidStartReplaying(scenarioName: String, success: Bool)
    func spooferDidStopReplaying(scenarioName: String)
}

@objc public class Spoofer: NSObject {
    
    // MARK: - Notifications
    public static let SpooferStartedRecordingNotification = "SpooferStartedRecordingNotification"
    public static let SpooferStoppedRecordingNotification = "SpooferStoppedRecordingNotification"
    public static let SpooferStartedReplayingNotification = "SpooferStartedReplayingNotification"
    public static let SpooferStoppedReplayingNotification = "SpooferStoppedReplayingNotification"

    // MARK: - Public properties
    public class var delegate: SpooferDelegate? {
        get {
            return self.sharedInstance.delegate
        }
        set {
            self.sharedInstance.delegate = newValue
        }
    }
    
    public class var domainsToSpoof: [String] {
        get {
            return self.sharedInstance.spoofedDomains
        }
        set {
            self.sharedInstance.spoofedDomains = newValue
        }
    }
    
    public class var queryParametersToIgnore: [String] {
        get {
            return self.sharedInstance.ignoredQueryParameters
        }
        set {
            self.sharedInstance.ignoredQueryParameters = newValue
        }
    }
    
    // MARK: - Internal methods and properties
    class func shouldHandleURL(url: NSURL) -> Bool {
        if domainsToSpoof.isEmpty {
            // Handle all cases in case no domains are whitelisted
            return true
        } else {
            // If whitelist is set, use it
            for hostDomain in domainsToSpoof {
                if hostDomain == url.host {
                    return true
                }
            }
            return false
        }
    }
    
    class var spoofedScenario: Scenario? {
        get {
            return Spoofer.sharedInstance.scenario
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
                logFormattedSeperator("Spoofer Recording Started")
            } else {
                logFormattedSeperator("Spoofer Recording Ended")
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
                logFormattedSeperator("Spoofer Replay Started")
            } else {
                logFormattedSeperator("Spoofer Replay Ended")
            }
        }
    }
    
    // MARK: - Internal variables
    static let sharedInstance = Spoofer()
    var scenario: Scenario? = nil
    var recording: Bool = false
    var replaying: Bool = false
    private var spoofedDomains = [String]()
    private var ignoredQueryParameters = [String]()
    private weak var delegate: SpooferDelegate?
}
