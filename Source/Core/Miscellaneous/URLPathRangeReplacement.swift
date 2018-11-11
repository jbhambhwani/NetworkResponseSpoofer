//
//  URLPathRangeReplacement.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 1/3/18.
//  Copyright © 2018 Hotwire. All rights reserved.
//

import Foundation

public struct URLPathRangeReplacement {
    public let start: String
    public let end: String?
    public let replacement: String

    public init(start: String, end: String? = nil, replacement: String = "") {
        self.start = start.lowercased()
        self.end = end?.lowercased()
        self.replacement = replacement.lowercased()
    }
}
