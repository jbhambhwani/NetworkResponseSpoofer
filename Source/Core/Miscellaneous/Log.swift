//
//  Log.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 5/8/19.
//  Copyright © 2019 Hotwire. All rights reserved.
//

import Foundation
import os

private let subsystem = "com.hotwire.networkresponsespoofer"

@available(iOS 12, OSX 10.14, *)
public struct Log {
    static let recorder = OSLog(subsystem: subsystem, category: "Spoofer Recorder")
    static let replayer = OSLog(subsystem: subsystem, category: "Spoofer Replayer")
}
