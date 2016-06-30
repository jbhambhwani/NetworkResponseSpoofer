//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

@objc public protocol SpooferDelegate {
    func spooferDidStartRecording(scenarioName: String)
    func spooferDidStopRecording(scenarioName: String, success: Bool)
    func spooferDidStartReplaying(scenarioName: String, success: Bool)
    func spooferDidStopReplaying(scenarioName: String)
}

@objc(Spoofer)
public class Spoofer: NSObject {
    
    // MARK - Notifications
    
    public static let spooferLogNotification = "SpooferLogNotification"
    public static let spooferStartedRecordingNotification = "SpooferStartedRecordingNotification"
    public static let spooferStoppedRecordingNotification = "SpooferStoppedRecordingNotification"
    public static let spooferStartedReplayingNotification = "SpooferStartedReplayingNotification"
    public static let spooferStoppedReplayingNotification = "SpooferStoppedReplayingNotification"
    
    // MARK: - Public properties
    
    public class var delegate: SpooferDelegate? {
        get { return sharedInstance.delegate }
        set { sharedInstance.delegate = newValue }
    }
    
    public class var configurations: [SpooferConfigurationType : AnyObject]? {
        return sharedInstance.config
    }
    
    public class var scenarioName: String {
        guard let scenario = spoofedScenario else { return String() }
        return scenario.name
    }
    
    public class var hostNamesToSpoof: [String] {
        get { return sharedInstance.spoofedHosts }
        set { sharedInstance.spoofedHosts = newValue.flatMap { $0.lowercaseString } }
    }
    
    public class var hostNamesToIgnore: [String] {
        get { return sharedInstance.ignoredHosts }
        set { sharedInstance.ignoredHosts = newValue.flatMap { $0.lowercaseString } }
    }
    
    public class var subDomainsToIgnore: [String] {
        get { return sharedInstance.ignoredSubdomains }
        set { sharedInstance.ignoredSubdomains = newValue.flatMap { $0.lowercaseString } }
    }
    
    public class var queryParametersToIgnore: [String] {
        get { return sharedInstance.ignoredQueryParameters }
        set { sharedInstance.ignoredQueryParameters = newValue.flatMap { $0.lowercaseString } }
    }

    public class var pathComponentsToIgnore: [String] {
        get { return sharedInstance.ignoredPathComponents }
        set { sharedInstance.ignoredPathComponents = newValue.flatMap { $0.lowercaseString } }
    }
    
    public class var normalizeQueryParameters: Bool {
        get { return sharedInstance.queryParameterNormalization }
        set { sharedInstance.queryParameterNormalization = newValue }
    }
    
    public class var allowSelfSignedCertificate: Bool {
        get { return sharedInstance.acceptSelfSignedCertificate }
        set { sharedInstance.acceptSelfSignedCertificate = newValue }
    }
    
    public class func resetConfigurations() {
        sharedInstance.spoofedHosts = [String]()
        sharedInstance.ignoredHosts = [String]()
        sharedInstance.ignoredSubdomains = [String]()
        sharedInstance.ignoredQueryParameters = [String]()
        sharedInstance.ignoredPathComponents = [String]()
        sharedInstance.acceptSelfSignedCertificate = false
        sharedInstance.queryParameterNormalization = false
    }
    
    // MARK: - Internal methods and properties
    
    class func shouldHandleURL(url: NSURL) -> Bool {
        // Take an early exit if host is empty
        guard let currentHost = url.host?.lowercaseString else { return false }
        
        // Handle all cases in case no domains are whitelisted and blacklisted
        if hostNamesToSpoof.isEmpty && hostNamesToIgnore.isEmpty { return true }
        
        let domainIsWhitelisted = hostNamesToSpoof.filter { currentHost.containsString($0) }.count > 0
        let domainIsBlacklisted = hostNamesToIgnore.filter { currentHost.containsString($0) }.count > 0

        if domainIsBlacklisted { return false }  // If same domain is Whitelisted and Blacklisted, prefer Blacklist. Users will have to clean up their act! :)
        if domainIsWhitelisted { return true }
        
        // Handle corner case when domain is not present in either whitelist or blacklist
        if !domainIsWhitelisted && !domainIsBlacklisted && hostNamesToSpoof.isEmpty {
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
    
    private var config: [SpooferConfigurationType: AnyObject]? {
        return [.queryParameterNormalization: queryParameterNormalization,
            .acceptSelfSignedCertificate: acceptSelfSignedCertificate,
            .spoofedHosts: spoofedHosts,
            .ignoredHosts: ignoredHosts,
            .ignoredSubdomains: ignoredSubdomains,
            .ignoredQueryParameters: ignoredQueryParameters,
            .ignoredPathComponents: ignoredPathComponents
        ]
    }
    
    static let sharedInstance = Spoofer()
    var scenario: Scenario? = nil
    var recording: Bool = false
    var replaying: Bool = false
    private var spoofedHosts = [String]()
    private var ignoredHosts = [String]()
    private var ignoredSubdomains = [String]()
    private var ignoredQueryParameters = [String]()
    private var ignoredPathComponents = [String]()
    private var acceptSelfSignedCertificate = false
    private var queryParameterNormalization = false
    private weak var delegate: SpooferDelegate?
}
