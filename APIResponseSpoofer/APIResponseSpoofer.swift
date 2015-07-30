//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class APIResponseSpoofer {
    
    class func startRecording(scenario: String? = "Default") -> Bool {
        NSURLProtocol.registerClass(RecorderProtocol)
        return true
    }
    
    class func stopRecording() -> Bool {
        NSURLProtocol.unregisterClass(RecorderProtocol)
        return true
    }
    
}
