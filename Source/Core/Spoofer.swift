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
    func spooferDidStopRecording(_ scenarioName: String)
    /**
     Method invoked on the delegate when the spoofer starts replaying a pre-recorded scenario

     - parameter scenarioName: The scenario name being replayed
     - parameter success: Boolean indicating successful replay start
     */
    func spooferDidStartReplaying(_ scenarioName: String)
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
        return sharedInstance.stateManager.state.scenarioName
    }

    /// The suite under which the scenario is being recorded or replayed. Returns empty when the Spoofer is not active
    public class var suiteName: String {
        return sharedInstance.stateManager.state.suiteName
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

    /// Blacklist of Path's. If set, these path names would be ignored from recording
    public class var pathsToIgnore: [String] {
        get { return sharedInstance.ignoredPaths }
        set { sharedInstance.ignoredPaths = newValue.flatMap { $0.lowercased() } }
    }

    /// Subdomains to normalize. Useful to ignore subdomain components like example.qa.com so the final URL is example.com. This is useful to record from one environment and playback in another.
    public class var subDomainsToNormalize: [String] {
        get { return sharedInstance.normalizedSubdomains }
        set { sharedInstance.normalizedSubdomains = newValue.flatMap { $0.lowercased() } }
    }

    /// Query parameters to normalize. Useful when query parameters are dynamic causing URL's to mismatch.
    public class var queryParametersToNormalize: [String] {
        get { return sharedInstance.normalizedQueryParameters }
        set { sharedInstance.normalizedQueryParameters = newValue.flatMap { $0.lowercased() } }
    }

    /// Path components that need to be ignored via URL normalization. Useful when path differs but the response is similar, as in the case of multiple API versions. e.g., v1, v1.1, v2 etc
    public class var pathComponentsToNormalize: [String] {
        get { return sharedInstance.normalizedPathComponents }
        set { sharedInstance.normalizedPathComponents = newValue.flatMap { $0.lowercased() } }
    }

    /// Path components that need to be replaced via URL normalization. Useful when path differs due to dynamic path components but the response is similar.
    /// For e.g. example.com/api/12?parm=value gets transformed to example.com/api/20?parm=value if this dict had an entry ["12": "20"]
    public class var pathRangesToReplace: [String: String] {
        get { return sharedInstance.replacePathRanges }

        set {
            let lowerCasedKeyValues = newValue.flatMap({ (key, value) -> (String, String) in
                return (key.lowercased(), value.lowercased())
            })
            sharedInstance.replacePathRanges = lowerCasedKeyValues.reduce([:], {
                var dict: [String: String] = $0
                dict[$1.0] = $1.1
                return dict
            })
        }
    }

    /**
     Enable normalizing query values, by taking only the keys and dropping the values.

     - Note: Query Value Normalization causes values (not keys) of the query parameters to be dropped while comparing URL's. For most cases this means only one response is saved per end point if the query parameter keys are the same. Effects are
     1. Reduced file size saving some storage space.
     2. Consistent response for the same end point regardless of query parameter values.

     For E.g., a url such as example.com/api?key1=value1&key2=value2 becomes example.com/api?key1&key2. This allows the Spoofer to record and replay the same reponse for all calls to the end point with similar key-value query parameters.
     */
    public class var normalizeQueryValues: Bool {
        get { return sharedInstance.queryValueNormalization }
        set { sharedInstance.queryValueNormalization = newValue }
    }

    /// Allows toggling accepting of self signed certificates
    public class var allowSelfSignedCertificate: Bool {
        get { return sharedInstance.acceptSelfSignedCertificate }
        set { sharedInstance.acceptSelfSignedCertificate = newValue }
    }

    // MARK: - Notifications

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

        if domainIsBlacklisted { return false } // If same domain is Whitelisted and Blacklisted, prefer Blacklist. Users will have to clean up their act! :)
        if domainIsWhitelisted { return true }

        // Handle corner case when domain is not present in either whitelist or blacklist
        if !domainIsWhitelisted && !domainIsBlacklisted && hostNamesToSpoof.isEmpty {
            return true
        }

        // Ignore the url if it has a black listed path component
        if url.pathComponents.filter({ pathsToIgnore.contains($0) }).count > 0 {
            return false
        }

        return false
    }

    class func resetConfigurations() {
        sharedInstance.spoofedHosts = [String]()
        sharedInstance.ignoredHosts = [String]()
        sharedInstance.ignoredPaths = [String]()
        sharedInstance.normalizedSubdomains = [String]()
        sharedInstance.normalizedQueryParameters = [String]()
        sharedInstance.normalizedPathComponents = [String]()
        sharedInstance.replacePathRanges = [String: String]()
        sharedInstance.acceptSelfSignedCertificate = false
        sharedInstance.queryValueNormalization = false
    }

    class var configurations: [SpooferConfigurationType: Any]? {
        return [
            .queryValueNormalization: Spoofer.normalizeQueryValues,
            .acceptSelfSignedCertificate: Spoofer.allowSelfSignedCertificate,
            .spoofedHosts: Spoofer.hostNamesToSpoof,
            .ignoredHosts: Spoofer.hostNamesToIgnore,
            .ignoredPaths: Spoofer.pathsToIgnore,
            .normalizedSubdomains: Spoofer.subDomainsToNormalize,
            .normalizedQueryParameters: Spoofer.queryParametersToNormalize,
            .normalizedPathComponents: Spoofer.pathComponentsToNormalize,
            .replacePathRanges: Spoofer.pathRangesToReplace,
        ]
    }

    // MARK: - Internal variables

    static let sharedInstance = Spoofer()
    let stateManager = SpooferStateManager()

    private var spoofedHosts = [String]()
    private var ignoredHosts = [String]()
    private var ignoredPaths = [String]()
    private var normalizedSubdomains = [String]()
    private var normalizedQueryParameters = [String]()
    private var normalizedPathComponents = [String]()
    private var replacePathRanges = [String: String]()
    private var acceptSelfSignedCertificate = false
    private var queryValueNormalization = false
    private weak var delegate: SpooferDelegate?
}
