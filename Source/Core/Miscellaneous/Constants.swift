//
//  Constants.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

/// Errors thrown by the Spoofer
public enum SpooferError: Int, Error {
    /// Error when unable to read from the scenario file on disk
    case diskReadError = 500
    /// Error when unable to write to a scenario file on disk
    case diskWriteError
    /// Error when unable to generate a scenario url
    case scenarioURLError
    /// Error when empty scenario file is found on disk
    case emptyFileError
    /// Error when unable to access sandboxed documents folder of the app
    case documentsAccessError
    /// Error when unable to create a folder inside the Documents folder
    case folderCreationError
    /// Error when scenario file has no APIResponses recorded
    case emptyScenarioError
    /// Error when no saved response is found for a particular request
    case noSavedResponseError
    /// Error when unable to delete a scenario from disk
    case scenarioDeletionError
}

// MARK: Internal

enum SpooferConfigurationType: String {
    case queryValueNormalization = "Query Value Normalization"
    case acceptSelfSignedCertificate = "Accept Self Signed Certificate"
    case spoofedHosts = "Hostnames to Spoof"
    case ignoredHosts = "Hostnames to Ignore"
    
    case ignoredSubdomains = "Normalized Subdomains"
    case ignoredQueryParameters = "Normalized Query Parameters"
    case ignoredPathComponents = "Normalized Path Components"
    case Blank = ""
    
    var allTypes: [SpooferConfigurationType] {
        return [.queryValueNormalization, .acceptSelfSignedCertificate, .spoofedHosts, .ignoredHosts, .ignoredSubdomains, .ignoredQueryParameters, .ignoredPathComponents, .Blank]
    }
    
    var description: String {
        switch self {
        case .queryValueNormalization:
            return "Query Value Normalization causes values (not keys) of the query parameters to be dropped while comparing URL's. For most cases this means only one response is saved per end point if the query parameter keys are the same. Effects are \n1. Reduced file size saving some storage space. \n2. Consistent response for the same end point regardless of query parameter values"
            
        case .acceptSelfSignedCertificate:
            return "Allows spoofer to proceed recording even when the certificate is not from a trusted authority"
            
        case .spoofedHosts:
            return "Whitelist for hostnames to be Spoofed"
            
        case .ignoredHosts:
            return "Blacklist for hostnames to be ignored"
            
        case .ignoredSubdomains:
            return "A general use case would be to ignore environments like QA, DEV, Staging etc which appear as part of the url. Causes URL hostnames to match production by removing these entries"
            
        case .ignoredQueryParameters:
            return "Use this when there are dynamic query parameter keys with each request which might cause lookup failure during replay"
            
        case .ignoredPathComponents:
            return "Use this setting when there are specific path components to be ignored during comparing URL's"
            
        case .Blank:
            return ""
        }
    }
}
