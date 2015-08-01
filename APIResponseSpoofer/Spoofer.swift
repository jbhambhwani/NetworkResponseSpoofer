//
//  APIResponseSpoofer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

@objc public class Spoofer {
    
    // MARK: Internal variables and shared instance
    static let sharedInstance = Spoofer()
    var scenario: Scenario? = nil
    var recording: Bool = false
    private var spoofedDomains = [String]()
    
    // MARK: Public properties
    public class var domainsToSpoof:[String]? {
        get {
        return self.sharedInstance.spoofedDomains
        }
        set {
            self.sharedInstance.spoofedDomains = newValue!
        }
    }
    
    // MARK: Public methods
    public class func startRecording(#scenarioName: String) -> Bool {
        let success = NSURLProtocol.registerClass(RecorderProtocol)
        if success {
            self.sharedInstance.scenario = Scenario(name: scenarioName)
            self.sharedInstance.recording = true
        }
        return success
    }
    
    public class func stopRecording() {
        NSURLProtocol.unregisterClass(RecorderProtocol)
        self.sharedInstance.scenario?.saveScenario({ success, scenario in
            self.sharedInstance.scenario = nil
            self.sharedInstance.recording = false
            }, errorHandler: { error in
                // TODO
        })
    }
    
    public class func isRecording() -> Bool {
        return self.sharedInstance.recording
    }
    
    // MARK: Internal methods
    class func shouldHandleURL(url: NSURL) -> Bool {
        // If whitelist is set, use it
        if domainsToSpoof!.count > 0 {
            for (index, hostDomain) in enumerate(domainsToSpoof!) {
                if hostDomain == url.host {
                    return true
                }
            }
            return false
        } else {
            // Handle all cases in case no domains are requested for
            return true
        }
    }
    
    class func addResponse(response: Response?) {
        if let newResponse = response {
            self.sharedInstance.scenario?.addResponse(newResponse)
        }
    }
    
}
