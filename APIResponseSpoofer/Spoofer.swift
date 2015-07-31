//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

@objc public class Spoofer {

    static let sharedInstance = Spoofer()
    var scenario: Scenario? = nil
    private var recording: Bool = false
    
    public class func startRecording(#scenarioName: String) -> Bool {
        let success = NSURLProtocol.registerClass(RecorderProtocol)
        if success {
            self.sharedInstance.scenario = Scenario(name: scenarioName)
            self.sharedInstance.recording = true
            println("------------------Response Spoofer Activated!---------------------")
        }
        return success
    }
    
    public class func stopRecording() {
        NSURLProtocol.unregisterClass(RecorderProtocol)
        Spoofer.sharedInstance.scenario?.saveScenario({ success, scenario in
            Spoofer.sharedInstance.scenario = nil
            Spoofer.sharedInstance.recording = false
            println("-----------------Response Spoofer Deactivated!--------------------")
        }, errorHandler: { error in
            
        })
    }
    
    public class func isRecording() -> Bool {
        return self.sharedInstance.recording
    }
    
}
