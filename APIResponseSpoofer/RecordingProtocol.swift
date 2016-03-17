//
//  RecordingProtocol.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class RecordingProtocol : NSURLProtocol {
 
    static let requestHandledKey = "RecorderProtocolHandledKey"
    var connection: NSURLConnection?
    var mutableData: NSMutableData?
    var response: NSURLResponse?
    
    override class func canInitWithRequest(request: NSURLRequest) -> Bool {
        guard let url = request.URL else { return false }
        
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = url.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist. If nothing is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(url)
        // 3: Check if the request was already handled. We set the below key in startLoading for handled requests
        let isHandled = (NSURLProtocol.propertyForKey(requestHandledKey, inRequest: request) != nil) ? true : false
        
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
        guard let newRequest = self.request.mutableCopy() as? NSMutableURLRequest else { return }
        // 2: Set a custom key in the request so that we don't have to handle it again and cause an infinite loop
        NSURLProtocol.setProperty(true, forKey: RecordingProtocol.requestHandledKey , inRequest: newRequest)
        // 3: Start a new connection to fetch the data
        self.connection = NSURLConnection(request: newRequest, delegate: self)
    }
    
    override func stopLoading() {
        self.connection?.cancel()
        self.connection = nil
    }
    
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace?) -> Bool {
        return protectionSpace?.authenticationMethod == NSURLAuthenticationMethodServerTrust
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge?) {
        
        guard let challenge = challenge, sender = challenge.sender else { return }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if Spoofer.allowSelfSignedCertificate {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    let credentials = NSURLCredential(forTrust: serverTrust)
                    sender.useCredential(credentials, forAuthenticationChallenge: challenge)
                }
            }
        }
        
        sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        // Send the received response to the client
        self.client?.URLProtocol(self, didReceiveResponse: response, cacheStoragePolicy: .NotAllowed)
        // Save / Initialize local structures
        self.response = response
        self.mutableData = NSMutableData()
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        // Send the received data to the client
        self.client?.URLProtocol(self, didLoadData: data)
        // Save all packets received
        self.mutableData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        // Let know the client that we completed loading the request
        self.client?.URLProtocolDidFinishLoading(self)
        // Save the response and data received as part of this request
        self.saveResponse()
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        // Pass error back to client
        self.client?.URLProtocol(self, didFailWithError: error)
        // Reset internal data structures
        self.mutableData = nil
        self.response = nil
    }
    
    func saveResponse() {
        guard let scenario = Spoofer.spoofedScenario, httpResponse = self.response else { return }
        // Create the internal data structure which encapsulates all the needed data to replay this response later
        guard let currentResponse = APIResponse(httpRequest: self.request, httpResponse: httpResponse, data: self.mutableData) else { return }
        // Save the response
        scenario.addResponse(currentResponse)
    }
    
}