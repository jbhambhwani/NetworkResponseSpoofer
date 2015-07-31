//
//  RecorderProtocol.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class RecorderProtocol : NSURLProtocol {
    
    var connection: NSURLConnection!
    var mutableData: NSMutableData!
    var response: NSURLResponse!
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        // If the request was already handled by the protocol, return
        if NSURLProtocol.propertyForKey("RecorderProtocolHandledKey", inRequest: request) != nil {
            return false
        }
        return true
    }
    
    override class func canonicalRequestForRequest(request: NSURLRequest) -> NSURLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(aRequest: NSURLRequest, toRequest bRequest: NSURLRequest) -> Bool {
        return super.requestIsCacheEquivalent(aRequest, toRequest:bRequest)
    }
    
    override func startLoading() {
        println("-------------Spoofer Protocol: Connecting to server---------------")
        // 1: Get a copy of the request
        var newRequest = self.request.mutableCopy() as! NSMutableURLRequest
        // 2: Set a custom key in the request so that we don't have to handle infinite loop
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
        // Create the internal data structure which encapsulates all the needed data to recreate this response
        let currentResponse:Response? = Response(requestURL: self.request.URL!.absoluteString!, method:self.request.HTTPMethod!, data: self.mutableData!, mimeType: self.response.MIMEType, encoding: self.response.textEncodingName)
        // Save the response
        if let newResponse = currentResponse {
            Spoofer.sharedInstance.scenario?.addResponse(newResponse)
            debugPrintln("Saving response \(newResponse)")
        }
    }
    
}