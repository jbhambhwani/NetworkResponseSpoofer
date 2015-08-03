//
//  RecordingProtocol.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class RecordingProtocol : NSURLProtocol {
    
    var connection: NSURLConnection!
    var mutableData: NSMutableData!
    var response: NSURLResponse!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = (request.URL!.scheme == "http") || (request.URL!.scheme == "https")
        // 2: Check if the request is to be handled or not based on a whitelist. If nothing is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(request.URL!)
        // 3: Check if the request was already handled. We set the below key in startLoading for handled requests
        let isHandled = (NSURLProtocol.propertyForKey("RecorderProtocolHandledKey", inRequest: request) != nil) ? true : false
        
        if isHTTP && !isHandled && shouldHandleURL {
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
        // 1: Get a copy of the original request
        var newRequest = self.request.mutableCopy() as! NSMutableURLRequest
        // 2: Set a custom key in the request so that we don't have to handle it again and cause an infinite loop
        NSURLProtocol.setProperty(true, forKey: "RecorderProtocolHandledKey", inRequest: newRequest)
        // 3: Start a new connection to fetch the data
        self.connection = NSURLConnection(request: newRequest, delegate: self)
    }
    
    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        // Send the received response to the client
        self.client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        // Save/Initialize local structures
        self.response = response
        self.mutableData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Send the received data to the client
        self.client!.URLProtocol(self, didLoadData: data)
        // Save all packets received
        self.mutableData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // Let know the client that we completed loading the request
        self.client!.URLProtocolDidFinishLoading(self)
        // Save the response and data received as part of this request
        self.saveResponse()
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        // Pass error back to client
        self.client!.URLProtocol(self, didFailWithError: error)
        // Reset internal data structures
        self.mutableData = nil
        self.response = nil
    }
    
    func saveResponse() {
        // Create the internal data structure which encapsulates all the needed data to replay this response later
        let currentResponse:APIResponse? = APIResponse(httpRequest: self.request, httpResponse: self.response, data: self.mutableData)
        // Save the response
        Spoofer.spoofedScenario!.addResponse(currentResponse!)
    }
    
}