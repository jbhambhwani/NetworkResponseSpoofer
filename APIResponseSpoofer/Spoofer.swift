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
        get { return sharedInstance.delegate }
        set { sharedInstance.delegate = newValue }
    }
    
    public class var hostNamesToSpoof: [String] {
        get { return sharedInstance.spoofedHosts }
        set { sharedInstance.spoofedHosts = newValue }
    }
    
    public class var hostNamesToIgnore: [String] {
        get { return sharedInstance.ignoredHosts }
        set { sharedInstance.ignoredHosts = newValue }
    }
    
    public class var subDomainsToIgnore: [String] {
        get { return sharedInstance.ignoredSubdomains }
        set { sharedInstance.ignoredSubdomains = newValue }
    }
    
    public class var queryParametersToIgnore: [String] {
        get { return sharedInstance.ignoredQueryParameters }
        set { sharedInstance.ignoredQueryParameters = newValue }
    }
    
    public class var normalizeQueryParameters: Bool {
        get { return sharedInstance.queryParameterNormalization }
        set { sharedInstance.queryParameterNormalization = newValue }
    }
    
    public class var allowSelfSignedCertificate: Bool {
        get { return sharedInstance.acceptSelfSignedCertificate }
        set { sharedInstance.acceptSelfSignedCertificate = newValue }
    }
    
    // MARK: - Internal methods and properties
    class func shouldHandleURL(url: NSURL) -> Bool {
        // Take an early exit if host is empty
        guard let host = url.host else { return false }
        
        // Handle all cases in case no domains are whitelisted
        if hostNamesToSpoof.isEmpty { return true }
        
        // If whitelist/blacklist is set, use it
        let whiteListedDomain = hostNamesToSpoof.filter() { host.containsString($0) }
        let blackListedDomain = hostNamesToIgnore.filter() { host.containsString($0) }
        
        if whiteListedDomain.count == 1 && blackListedDomain.count == 0 {
            return true
        }
        
        return false
    }
    
    class var spoofedScenario: Scenario? {
        get { return sharedInstance.scenario }
        set { sharedInstance.scenario = newValue }
    }
    
    class var setRecording: Bool {
        get { return sharedInstance.recording }
        
        set {
            sharedInstance.recording = newValue
            if newValue {
                logFormattedSeperator("Spoofer Recording Started")
            } else {
                logFormattedSeperator("Spoofer Recording Ended")
            }
        }
    }
    
    class var setReplaying: Bool {
        get { return sharedInstance.replaying }
        
        set {
            sharedInstance.replaying = newValue
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
    private var spoofedHosts = [String]()
    private var ignoredHosts = [String]()
    private var ignoredSubdomains = [String]()
    private var ignoredQueryParameters = [String]()
    private var acceptSelfSignedCertificate = false
    private var queryParameterNormalization = false
    private weak var delegate: SpooferDelegate?
}
