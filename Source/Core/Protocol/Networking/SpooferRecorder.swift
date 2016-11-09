//
//  SpooferRecorder.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

public class SpooferRecorder: URLProtocol, NetworkInterceptable {
 
    static let requestHandledKey = "RecorderProtocolHandledKey"
    var connection: NSURLConnection?
    var response: URLResponse?
    var responseData: Data?
    
    override public class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = url.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist. If nothing is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(url)
        // 3: Check if the request was already handled. We set the below key in startLoading for handled requests
        let isHandled = (URLProtocol.property(forKey: requestHandledKey, in: request) != nil) ? true : false
        
        if Spoofer.isRecording && isHTTP && !isHandled && shouldHandleURL {
            return true
        }
        return false
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public class func requestIsCacheEquivalent(_ aRequest: URLRequest, to bRequest: URLRequest) -> Bool {
        // Let the super class handle it
        return super.requestIsCacheEquivalent(aRequest, to:bRequest)
    }
    
    override public func startLoading() {
        // 1: Get a copy of the original request
        guard let newRequest = request as? MutableURLRequest else { return }
        // 2: Set a custom key in the request so that we don't have to handle it again and cause an infinite loop
        URLProtocol.setProperty(true, forKey: SpooferRecorder.requestHandledKey , in: newRequest)
        // 3: Start a new connection to fetch the data
        connection = NSURLConnection(request: newRequest as URLRequest, delegate: self)
    }
    
    override public func stopLoading() {
        connection?.cancel()
        connection = nil
    }
    
    func connection(_ connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: URLProtectionSpace?) -> Bool {
        return protectionSpace?.authenticationMethod == NSURLAuthenticationMethodServerTrust
    }
    
    func connection(_ connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge?) {
        
        guard let challenge = challenge, let sender = challenge.sender else { return }
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if Spoofer.allowSelfSignedCertificate {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    let credentials = URLCredential(trust: serverTrust)
                    sender.use(credentials, for: challenge)
                }
            }
        }
        
        sender.continueWithoutCredential(for: challenge)
    }
    
    func connection(_ connection: NSURLConnection, didReceiveResponse response: URLResponse) {
        // Send the received response to the client
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        // Save / Initialize local structures
        self.response = response
        responseData = Data()
    }
    
    func connection(_ connection: NSURLConnection, didReceiveData data: Data) {
        // Send the received data to the client
        client?.urlProtocol(self, didLoad: data)
        // Save all packets received
        responseData?.append(data)
    }
    
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        // Let know the client that we completed loading the request
        client?.urlProtocolDidFinishLoading(self)
        // Save the response and data received as part of this request
        saveResponse()
    }
    
    func connection(_ connection: NSURLConnection, didFailWithError error: NSError) {
        // Pass error back to client
        client?.urlProtocol(self, didFailWithError: error)
        // Reset internal data structures
        response = nil
        responseData = nil
    }
    
    func saveResponse() {
        guard Spoofer.scenarioName.isEmpty == false, let httpResponse = response else { return }
        
        // Create the internal data structure which encapsulates all the needed data to replay this response later
        guard let currentResponse = APIResponseV2.responseFrom(httpRequest: request, httpResponse: httpResponse, data: responseData) else { return }
        
        postNotification("Response received:\n\(currentResponse)", object: self)
        DataStore.save(response: currentResponse, scenarioName: Spoofer.scenarioName)
    }
    
}
