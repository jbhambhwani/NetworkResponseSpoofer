//
//  Constants.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
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
    case ScenarioDeletionError = 507
}

public enum SpooferConfigurationType: String {
    case queryParameterNormalization = "Query Parameter Normalization"
    case acceptSelfSignedCertificate = "Accept Self Signed Certificate"
    case spoofedHosts = "Hostnames to Spoof"
    case ignoredHosts = "Hostnames to Ignore"
    case ignoredSubdomains = "Subdomains to Ignore"
    case ignoredQueryParameters = "Query Parameters to Ignore"
    case None = ""
    
    var description: String {
        switch self {
            case queryParameterNormalization:
                return "Query Parameter Normalization causes values (not keys) of the query parameters to be dropped while comparing URL's. For most cases this means only one response is saved per end point if the query parameter keys are the same. Effects are \n1. Reduced scenario file size saving some storage space. \n2. Consistent response for the same end point to make testing easier"
            
            case acceptSelfSignedCertificate:
                return "Allows spoofer to proceed recording even when the certificate is not from a trusted authority"
            
            case spoofedHosts:
                return "Whitelist for hostnames to be Spoofed"
            
            case ignoredHosts:
                return "Blacklist for hostnames to be ignored"
            
            case ignoredSubdomains:
                return "Subdomain names to be ignored. A general use case would be to ignore environments like QA, DEV, Staging etc which appear as part of the url. Causes URL hostnames to match production by removing these entries"
            
            case ignoredQueryParameters:
                    return "Use this when there are dynamic query parameter keys with each request which might cause lookup failure during replay"
            
            default: return ""
        }
    }
}
