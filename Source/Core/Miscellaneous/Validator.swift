//
//  Validator.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/25/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import Foundation

struct Validator {

    // Validates that all strings passed in are not empty
    static func validateNotEmpty(stringArray: [String]) -> Bool {
        let emptyStrings: [String] = stringArray.filter {
            return $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count == 0
        }
        return emptyStrings.count == 0
    }
}
