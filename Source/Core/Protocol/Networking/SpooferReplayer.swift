//
//  SpooferReplayer.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 8/1/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

enum ReplayMethod {
    case statusCodeAndHeader
    case mimeTypeAndEncoding
}

public class SpooferReplayer: URLProtocol, NetworkInterceptable {
    
    private var currentReplayMethod: ReplayMethod {
        // Customization: Switch the replay method according to the one which suits your specific requirement.
        return .statusCodeAndHeader
    }
    
    override public class func canInit(with request: URLRequest) -> Bool {
         guard let url = request.url else { return false }
        
        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = url.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist. If no whitelist is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(url)
        // 3: Check if we have a scenario loaded in memory
        let hasSavedScenario = (Spoofer.spoofedScenario != nil) ? true : false
        
        if Spoofer.isReplaying && isHTTP && shouldHandleURL && hasSavedScenario {
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
        guard let url = request.url else { return }
        
        guard let spoofedScenario = Spoofer.spoofedScenario, let cachedResponse = spoofedScenario.responseForRequest(request) else {
            // Throw an error in case we are unable to load a response
            let httpError = handleError("No saved response found", recoveryMessage: "You might need to re-record the scenario", code: SpooferError.noSavedResponseError.rawValue, url: url.absoluteString, errorHandler: nil)
            client?.urlProtocol(self, didFailWithError: httpError)
            return
        }
        
        var httpResponse: HTTPURLResponse?
        
        switch currentReplayMethod {
            case .statusCodeAndHeader:
                let statusCode = (cachedResponse.statusCode >= 200) ? cachedResponse.statusCode : 200
                httpResponse = HTTPURLResponse(url: cachedResponse.requestURL, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: cachedResponse.headerFields as? [String : String])
            case .mimeTypeAndEncoding:
                httpResponse = HTTPURLResponse(url: cachedResponse.requestURL, mimeType: cachedResponse.mimeType, expectedContentLength: cachedResponse.expectedContentLength, textEncodingName: cachedResponse.encoding)
        }

        guard let spoofedResponse = httpResponse else {
            // Throw an error in case we are unable to serialize a response
            let httpError = handleError("No saved response found", recoveryMessage: "You might need to re-record the scenario", code: SpooferError.noSavedResponseError.rawValue, url: url.absoluteString, errorHandler: nil)
            client?.urlProtocol(self, didFailWithError: httpError)
            return
        }
        
        postNotification("Serving response from 💾: \(url)", object: self)
        
        client?.urlProtocol(self, didReceive: spoofedResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: cachedResponse.data)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override public func stopLoading() {
        // Nothing to do here for replay
    }
    
}