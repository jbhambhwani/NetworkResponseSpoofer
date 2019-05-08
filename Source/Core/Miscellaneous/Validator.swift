//
//  Validator.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 1/25/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import Foundation

public struct Validator {
    // Validates that all strings passed in are not empty
    public static func validateNotEmpty(stringArray: [String]) -> Bool {
        let emptyStrings: [String] = stringArray.filter {
            !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        }
        return !emptyStrings.isEmpty
    }
}
