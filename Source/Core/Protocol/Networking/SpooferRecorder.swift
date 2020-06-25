//
//  SpooferRecorder.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation
import os

/**
 URLProtocol subclass to be inserted in your URLSessionConfiguration.protocols stack to enable Recording.
 The methods are not to be overriden for Spoofer to work correctly.
 */
public final class SpooferRecorder: URLProtocol, NetworkInterceptable {
    static let requestHandledKey = "RecorderProtocolHandledKey"
    var session: URLSession?
    var dataTask: URLSessionDataTask?
    var response: URLResponse?
    var responseData: Data?
    var requestData: Data?

    public override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }

        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = url.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist.
        // If nothing is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(url)
        // 3: Check if the request was already handled. We set the below key in startLoading for handled requests
        let isHandled = !(request.value(forHTTPHeaderField: requestHandledKey) ?? "").isEmpty

        if Spoofer.isRecording, isHTTP, !isHandled, shouldHandleURL {
            return true
        }

        if shouldHandleURL == false, let url = request.url {
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("⏩ Skipped unhandled url: %s", log: .recorder, type: .info, url.absoluteString)
            }
            postNotification("⏩ Skipped unhandled url: \(url)")
        }

        return false
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override class func requestIsCacheEquivalent(_ aRequest: URLRequest, to bRequest: URLRequest) -> Bool {
        // Let the super class handle it
        return super.requestIsCacheEquivalent(aRequest, to: bRequest)
    }

    public override func startLoading() {
        // 1: Get a copy of the original request
        var newRequest = request
        // 2: Set a custom key in the request so that we don't have to handle it again and cause an infinite loop
        newRequest.setValue("yes", forHTTPHeaderField: SpooferRecorder.requestHandledKey)
        // 3: Start a new session to fetch the data
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: newRequest)
        dataTask?.resume()
    }

    public override func stopLoading() {
        dataTask?.cancel()
        session?.invalidateAndCancel()
        session = nil
        dataTask = nil
        response = nil
        responseData = nil
    }
}

// MARK: - Networking Delegates

extension SpooferRecorder: URLSessionDataDelegate, URLSessionTaskDelegate {
    public func urlSession(_: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            Spoofer.allowSelfSignedCertificate == true,
            let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let credentials = URLCredential(trust: serverTrust)
        completionHandler(.performDefaultHandling, credentials)
    }

    public func urlSession(_: URLSession,
                           dataTask _: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        // Send the received response to the client
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        // Save / Initialize local structures
        self.response = response
        responseData = Data()
        requestData = dataTask?.currentRequest?.httpJSONBodyStream
        completionHandler(.allow)
    }

    public func urlSession(_: URLSession, dataTask _: URLSessionDataTask, didReceive data: Data) {
        // Send the received data to the client
        client?.urlProtocol(self, didLoad: data)
        // Save all packets received
        responseData?.append(data)
    }

    public func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            // Pass error back to client
            client?.urlProtocol(self, didFailWithError: error)
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("❌ Record failure: %s", log: .recorder, type: .error, error.localizedDescription)
            }
            postNotification("❌ Record failure: \(error.localizedDescription)", object: self)
            // Reset internal data structures
            response = nil
            responseData = nil
        } else {
            // Let know the client that we completed loading the request
            client?.urlProtocolDidFinishLoading(self)
            // Save the response and data received as part of this request
            saveResponse()
        }
    }
}

// MARK: - Response Persistance

extension SpooferRecorder {
    public func saveResponse() {
        guard Spoofer.scenarioName.isEmpty == false, let httpResponse = response else { return }

        // Create the internal data structure which encapsulates all the needed data to replay this response later
        guard let currentResponse = NetworkResponse.responseFrom(httpRequest: request,
                                                                 httpResponse: httpResponse,
                                                                 requestData: requestData,
                                                                 responseData: responseData) else { return }
        let saveResult = DataStore.save(response: currentResponse,
                                        scenarioName: Spoofer.scenarioName,
                                        suite: Spoofer.suiteName)
        switch saveResult {
        case let .success(response):
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("📡 Response saved: %@", log: .recorder, response)
            }
            postNotification("📡 Response saved: \(response)", object: self)
        case let .failure(error):
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("❌ Response Not saved: %s", log: .recorder, type: .error, error.localizedDescription)
            }
            postNotification("❌ Response Not saved: \(error.localizedDescription)", object: self)
        }
    }
}
