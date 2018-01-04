//
//  URLPathRangeReplacement.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/3/18.
//  Copyright © 2018 Hotwire. All rights reserved.
//

import Foundation

public struct URLPathRangeReplacement {
    let start: String
    let end: String?
    let replacement: String

    init(start: String, end: String? = nil, replacement: String = "") {
        self.start = start.lowercased()
        self.end = end?.lowercased()
        self.replacement = replacement.lowercased()
    }
}
