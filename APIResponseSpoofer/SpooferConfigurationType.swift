//
//  SpooferConfigurationType.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

public enum SpooferConfigurationType: String {
    case queryParameterNormalization = "Query Parameter Normalization"
    case acceptSelfSignedCertificate = "Accept Self Signed Certificate"
    case spoofedHosts = "Hostnames to Spoof"
    case ignoredHosts = "Hostnames to Ignore"
    case ignoredSubdomains = "Subdomains to Ignore"
    case ignoredQueryParameters = "Query Parameters to Ignore"
    case None = ""
}