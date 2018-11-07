//
//  Utility.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 10/11/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation

func logFormattedSeperator(_ message: String? = "-") {
    guard let message = message else { return }

    postNotification(message)

    // Print "-" character before and after the message, 100 character total. Just logging every important message nicely.
    let messageStart = 50 - (message.count / 2)
    if messageStart > 0 {
        let hyphenString = String(repeating: "-", count: messageStart)
        print("\(hyphenString)\(message)\(hyphenString)")
    } else {
        print("Message too long for formatting: \(message)")
    }
}

func postNotification(_ message: String, object: Any? = nil) {
    var message = message
    message = "SpooferLog " + message
    // Print to console
    print(message)
    // Post a notification with the message so that any receivers can listen and log it
    NotificationCenter.default.post(name: Notification.Name(rawValue: Spoofer.spooferLogNotification), object: object, userInfo: ["message": message])
}

@discardableResult func generateError(_ reason: String, recoveryMessage: String, code: Int, url: String? = nil, errorHandler: ((_ error: NSError) -> Void)?) -> NSError {
    var userInfo = [NSLocalizedFailureReasonErrorKey: reason, NSLocalizedRecoverySuggestionErrorKey: recoveryMessage]
    if let url = url {
        userInfo[NSURLErrorFailingURLErrorKey] = url
    }
    let spooferError = NSError(domain: "NetworkResponseSpoofer", code: code, userInfo: userInfo)
    errorHandler?(spooferError)
    return spooferError
}
