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
        println("Custom Protocol: Connecting to server")
        var newRequest = self.request.mutableCopy() as! NSMutableURLRequest
        NSURLProtocol.setProperty(true, forKey: "RecorderProtocolHandledKey", inRequest: newRequest)
        self.connection = NSURLConnection(request: newRequest, delegate: self)
    }
    
    override func stopLoading() {
        if self.connection != nil {
            self.connection.cancel()
        }
        self.connection = nil
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        self.client!.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        self.response = response
        self.mutableData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        self.client!.URLProtocol(self, didLoadData: data)
        self.mutableData.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        self.client!.URLProtocolDidFinishLoading(self)
        self.saveCachedResponse()
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        self.client!.URLProtocol(self, didFailWithError: error)
        self.mutableData = nil
        self.response = nil
    }
    
    func saveCachedResponse() {
        println("Saving cached response")
        
        var cachedResponse = Dictionary<NSObject, AnyObject>()
        cachedResponse["data"] = self.mutableData
        cachedResponse["url"] = self.request.URL!.absoluteString
        cachedResponse["timestamp"] = NSDate()
        cachedResponse["mimetype"] = self.response.MIMEType
        cachedResponse["encoding"] = self.response.textEncodingName
        
        println("\n\(cachedResponse)\n")
    }

}