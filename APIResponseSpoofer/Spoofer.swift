//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class Spoofer {

    static let sharedInstance = Spoofer()
    var scenario: Scenario? = nil
    private var recording: Bool = false
    
    class func startRecording(#scenario: Scenario) -> Bool {
        let success = NSURLProtocol.registerClass(RecorderProtocol)
        self.sharedInstance.scenario = scenario
        self.sharedInstance.recording = true
        return success
    }
    
    class func stopRecording() {
        NSURLProtocol.unregisterClass(RecorderProtocol)
        Spoofer.sharedInstance.scenario?.saveScenario({ success, scenario in
            Spoofer.sharedInstance.scenario = nil
            Spoofer.sharedInstance.recording = false
        }, errorHandler: { error in
            
        })
    }
    
    class func isRecording() -> Bool {
        return self.sharedInstance.recording
    }
    
}
