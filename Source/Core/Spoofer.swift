//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

/**
 *  Delegate methods invoked by Spoofer whenever its state changes
 */
@objc public protocol SpooferDelegate {
    /**
     Method invoked on the delegate when spoofer starts recording a scenario
     
     - parameter scenarioName: The scenario name under which all the responses are going to be captured
     */
    func spooferDidStartRecording(_ scenarioName: String)
    /**
     Method invoked on the delegate when the spoofer stops recording a scenario
     
     - parameter scenarioName: The scenario name under which all the responses were captured
     - parameter success: Boolean indicating if recording was successful
     */
    func spooferDidStopRecording(_ scenarioName: String, success: Bool)
    /**
     Method invoked on the delegate when the spoofer starts replaying a pre-recorded scenario
     
     - parameter scenarioName: The scenario name being replayed
     - parameter success: Boolean indicating successful replay start
     */
    func spooferDidStartReplaying(_ scenarioName: String, success: Bool)
    /**
     Method invoked on the delegate when the spoofer stops replay of a given scenario
     
     - parameter scenarioName: The scenario name which just stopped replay
     */
    func spooferDidStopReplaying(_ scenarioName: String)
}

/**
 APIResponseSpoofer is a network request-response recording and replaying library for iOS. It's built on top of the [Foundation URL Loading System](http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html) to make recording and replaying network requests really simple.
 */
@objc(Spoofer)
public class Spoofer: NSObject {
    
    // MARK: - Configuration
    
    /// The delegate for the Spoofer, which will be notified whenever the Spoofer state changes
    public class var delegate: SpooferDelegate? {
        get { return sharedInstance.delegate }
        set { sharedInstance.delegate = newValue }
    }
    
    /// The scenario name being recorded or replayed. Returns empty when the Spoofer is not active
    public class var scenarioName: String {
        guard let scenario = spoofedScenario else { return String() }
        return scenario.name
    }
    
    /// White list of host names the Spoofer would intercept. If set, only whitelist host names would be recorded
    public class var hostNamesToSpoof: [String] {
        get { return sharedInstance.spoofedHosts }
        set { sharedInstance.spoofedHosts = newValue.flatMap { $0.lowercased() } }
    }
    
    /// Blacklist of hostnames. If set, these host names would be ignored from recording
    public class var hostNamesToIgnore: [String] {
        get { return sharedInstance.ignoredHosts }
        set { sharedInstance.ignoredHosts = newValue.flatMap { $0.lowercased() } }
    }
    
    /// Subdomains to ignore via URL normalization. Useful to ignore subdomain components like example.qa.com so the final URL is example.com. This is useful to record from one environment and playback in another.
    public class var subDomainsToIgnore: [String] {
        get { return sharedInstance.ignoredSubdomains }
        set { sharedInstance.ignoredSubdomains = newValue.flatMap { $0.lowercased() } }
    }
    
    /// Query parameters that should be ignored via URL normalization. Useful when query parameters are dynamic causing URL's to mismatch.
    public class var queryParametersToIgnore: [String] {
        get { return sharedInstance.ignoredQueryParameters }
        set { sharedInstance.ignoredQueryParameters = newValue.flatMap { $0.lowercased() } }
    }

    /** Path components that need to be ignored via URL normalization. Useful when path differs but the response is similar, as in the case of multiple API versions.
        E.g. v1, v1.1, v2 etc
    */
    public class var pathComponentsToIgnore: [String] {
        get { return sharedInstance.ignoredPathComponents }
        set { sharedInstance.ignoredPathComponents = newValue.flatMap { $0.lowercased() } }
    }
    
    /** 
     Enable normalizing query parameters, by taking only the keys and dropping the values.
     
     - Note: Query Parameter Normalization causes values (not keys) of the query parameters to be dropped while comparing URL's. For most cases this means only one response is saved per end point if the query parameter keys are the same. Effects are
     1. Reduced scenario file size saving some storage space.
     2. Consistent response for the same end point regardless of query parameter values. 
     
     For E.g., a url such as example.com/api?key1=value1&key2=value2 becomes example.com/api?key1&key2. This allows the Spoofer to record and replay the same reponse for all calls to the end point with similar key-value query parameters.
     */
    public class var normalizeQueryParameters: Bool {
        get { return sharedInstance.queryParameterNormalization }
        set { sharedInstance.queryParameterNormalization = newValue }
    }
    
    /// Allows toggling accepting of self signed certificates
    public class var allowSelfSignedCertificate: Bool {
        get { return sharedInstance.acceptSelfSignedCertificate }
        set { sharedInstance.acceptSelfSignedCertificate = newValue }
    }
    
    // MARK - Notifications
    
    /**
     Fired whenever the Spoofer logs some meaningful output, as in request intercept, record start/stop etc
     - Note: The userInfo dictionary of the notification has a "message" key, the value contains the log from the spoofer
     */
    public static let spooferLogNotification = "SpooferLogNotification"
    /** Notification fired when spoofer starts recording a scenario.
     - Note: Userinfo dictionary has key "scenario" which has the name of the scenario
    */
    public static let spooferStartedRecordingNotification = "SpooferStartedRecordingNotification"
    /// Notification fired when spoofer stops recording a scenario. Userinfo dictionary has key "scenario" which has the name of the scenario
    public static let spooferStoppedRecordingNotification = "SpooferStoppedRecordingNotification"
    /// Notification fired when spoofer starts replaying a scenario. Userinfo dictionary has key "scenario" which has the name of the scenario
    public static let spooferStartedReplayingNotification = "SpooferStartedReplayingNotification"
    /// Notification fired when spoofer stops replaying a scenario. Userinfo dictionary has key "scenario" which has the name of the scenario
    public static let spooferStoppedReplayingNotification = "SpooferStoppedReplayingNotification"

    
    // MARK: - Internal methods and properties
    
    class func shouldHandleURL(_ url: URL) -> Bool {
        // Take an early exit if host is empty
        guard let currentHost = url.host?.lowercased() else { return false }
        
        // Handle all cases in case no domains are whitelisted and blacklisted
        if hostNamesToSpoof.isEmpty && hostNamesToIgnore.isEmpty { return true }
        
        let domainIsWhitelisted = hostNamesToSpoof.filter { currentHost.contains($0) }.count > 0
        let domainIsBlacklisted = hostNamesToIgnore.filter { currentHost.contains($0) }.count > 0

        if domainIsBlacklisted { return false }  // If same domain is Whitelisted and Blacklisted, prefer Blacklist. Users will have to clean up their act! :)
        if domainIsWhitelisted { return true }
        
        // Handle corner case when domain is not present in either whitelist or blacklist
        if !domainIsWhitelisted && !domainIsBlacklisted && hostNamesToSpoof.isEmpty {
            return true
        }

        return false
    }
    
    class var spoofedScenario: ScenarioV2? {
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
    
    class func resetConfigurations() {
        sharedInstance.spoofedHosts = [String]()
        sharedInstance.ignoredHosts = [String]()
        sharedInstance.ignoredSubdomains = [String]()
        sharedInstance.ignoredQueryParameters = [String]()
        sharedInstance.ignoredPathComponents = [String]()
        sharedInstance.acceptSelfSignedCertificate = false
        sharedInstance.queryParameterNormalization = false
    }
    
    class var configurations: [SpooferConfigurationType : Any]? {
        return sharedInstance.config
    }
    
    // MARK: - Internal variables
    
    private lazy var config: [SpooferConfigurationType: Any] = {
        return [.queryParameterNormalization: sharedInstance.queryParameterNormalization as Any,
            .acceptSelfSignedCertificate: sharedInstance.acceptSelfSignedCertificate as Any,
            .spoofedHosts: sharedInstance.spoofedHosts as Any,
            .ignoredHosts: sharedInstance.ignoredHosts as Any,
            .ignoredSubdomains: sharedInstance.ignoredSubdomains as Any,
            .ignoredQueryParameters: sharedInstance.ignoredQueryParameters as Any,
            .ignoredPathComponents: sharedInstance.ignoredPathComponents as Any
        ]
    }()
    
    static let sharedInstance = Spoofer()
    var scenario: ScenarioV2? = nil
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
