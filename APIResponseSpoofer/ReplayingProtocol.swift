//
//  ReplayingProtocol.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/1/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class ReplayingProtocol : NSURLProtocol {
    
    var mutableData: NSMutableData!
    var response: NSURLResponse!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = (request.URL!.scheme == "http") || (request.URL!.scheme == "https")
        // 2: Check if the request is to be handled or not based on a whitelist. If nothing is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(request.URL!)
        // 3: Check if we have a scenario loaded in memory
        let hasSavedScenario = (Spoofer.spoofedScenario != nil) ? true : false
        
        // TODO: Also check if the scenario has a response matching the criteria (url, headers etc) for the current request
        if isHTTP && shouldHandleURL && hasSavedScenario {
            return true
        }
        return false
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(aRequest: NSURLRequest, toRequest bRequest: NSURLRequest) -> Bool {
        // Let the super class handle it
        return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
    }
    
    override func startLoading() {
        let success:Bool = false
        if let cachedResponse = Spoofer.spoofedScenario?.responseForRequest(self.request) {
            let httpResponse = NSHTTPURLResponse(URL: cachedResponse.requestURL, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: cachedResponse.headerFields)
            self.client?.URLProtocol(self, didReceiveResponse: httpResponse!, cacheStoragePolicy: .NotAllowed)
            self.client?.URLProtocol(self, didLoadData: cachedResponse.data!)
            self.client?.URLProtocolDidFinishLoading(self)
        } else {
            // TODO: Throw a valid error
            self.client?.URLProtocol(self, didFailWithError: NSError())
        }
    }
    
    override func stopLoading() {
        // Do nothing
    }
    
}