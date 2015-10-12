//
//  Utility.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation

func logFormattedSeperator(message: String? = "-") {
    guard let message = message else { return }
    let messageStart = 50 - (message.characters.count / 2)
    if messageStart > 0 {
        let hyphen = Character("-")
        let hyphenString = String(count: messageStart, repeatedValue: hyphen)
        print("\(hyphenString)\(message)\(hyphenString)")
    } else {
        print("Message too long for formatting: \(message)")
    }
}