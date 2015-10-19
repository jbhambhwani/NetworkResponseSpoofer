//
//  ReplayingProtocol.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/1/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

enum ReplayMethod {
    case StatusCodeAndHeader
    case MimeTypeAndEncoding
}

class ReplayingProtocol : NSURLProtocol {
    
    private var currentReplayMethod: ReplayMethod {
        // Customization: Switch the replay method according to the one which suits your specific requirement.
        return ReplayMethod.MimeTypeAndEncoding
    }
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = request.URL!.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist. If no whitelist is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(request.URL!)
        // 3: Check if we have a scenario loaded in memory
        let hasSavedScenario = (Spoofer.spoofedScenario != nil) ? true : false
        
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
        guard let cachedResponse = Spoofer.spoofedScenario?[self.request] else {
            // Throw an error in case we are unable to load a response
            let httpError = handleError("No saved response found", recoveryMessage: "You might need to re-record the scenario", code: SpooferError.NoSavedResponseError.rawValue, url: self.request.URL!.absoluteString, errorHandler: nil)
            self.client?.URLProtocol(self, didFailWithError: httpError)
            return
        }
        
        var httpResponse: NSHTTPURLResponse?
        switch currentReplayMethod {
        case .StatusCodeAndHeader:
            httpResponse = NSHTTPURLResponse(URL: cachedResponse.requestURL, statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: cachedResponse.headerFields)
        case .MimeTypeAndEncoding:
            httpResponse = NSHTTPURLResponse(URL: cachedResponse.requestURL, MIMEType: cachedResponse.mimeType, expectedContentLength: -1, textEncodingName: cachedResponse.encoding)
        }

        guard let spoofedResponse = httpResponse else {
            // Throw an error in case we are unable to serialize a response
            let httpError = handleError("No saved response found", recoveryMessage: "You might need to re-record the scenario", code: SpooferError.NoSavedResponseError.rawValue, url: self.request.URL!.absoluteString, errorHandler: nil)
            self.client?.URLProtocol(self, didFailWithError: httpError)
            return
        }
        
        postNotification("Serving response from cache for : \(self.request.URL?.absoluteString)")
        
        self.client?.URLProtocol(self, didReceiveResponse: spoofedResponse, cacheStoragePolicy: .NotAllowed)
        self.client?.URLProtocol(self, didLoadData: cachedResponse.data!)
        self.client?.URLProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        // Do nothing
    }
    
}