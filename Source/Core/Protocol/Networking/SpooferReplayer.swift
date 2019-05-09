//
//  SpooferReplayer.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 8/1/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation
import os

enum ReplayMethod {
    case statusCodeAndHeader
    case mimeTypeAndEncoding
}

/**
 URLProtocol subclass to be inserted in your URLSessionConfiguration.protocols stack to enable Replaying.
 The methods are not to be overriden for Spoofer to work correctly.
 */
public final class SpooferReplayer: URLProtocol, NetworkInterceptable {
    private var currentReplayMethod: ReplayMethod {
        // Customization: Switch the replay method according to the one which suits your specific requirement.
        return .statusCodeAndHeader
    }

    public override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }

        // 1: Check the request's scheme. Only HTTP/HTTPS is supported right now
        let isHTTP = url.isHTTP
        // 2: Check if the request is to be handled or not based on a whitelist. If no whitelist is set all requests are handled
        let shouldHandleURL = Spoofer.shouldHandleURL(url)
        // 3: Check if we have a scenario loaded in memory
        let hasSavedScenario = Spoofer.scenarioName.isEmpty == false

        if Spoofer.isReplaying, isHTTP, shouldHandleURL, hasSavedScenario {
            return true
        }

        if shouldHandleURL == false, let url = request.url {
            if #available(iOS 12.0, *) {
                os_log(.info, log: Log.replayer, "⏩ Skipped unhandled url: %s", url.absoluteString)
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
        guard let url = request.url else {
            return
        }
        let urlString = url.absoluteString

        let httpError = generateError("No saved response found",
                                      recoveryMessage: "You might need to re-record the scenario",
                                      code: SpooferError.noSavedResponseError.rawValue,
                                      url: url.absoluteString,
                                      errorHandler: nil)

        let loadResult = DataStore.load(scenarioName: Spoofer.scenarioName, suite: Spoofer.suiteName)
        switch loadResult {
        case let .success(scenario):
            guard let cachedResponse = scenario.responseForRequest(request),
                URL(string: cachedResponse.requestURL) != nil else {
                if #available(iOS 12.0, *) {
                    os_log(.debug, log: Log.replayer, "⚠️ No saved response found: %s", urlString)
                }
                postNotification("⚠️ No saved response found: \(urlString))", object: self)
                // Throw an error in case we are unable to load a response
                client?.urlProtocol(self, didFailWithError: httpError)
                return
            }

            var httpResponse: HTTPURLResponse?
            switch currentReplayMethod {
            case .statusCodeAndHeader:
                let statusCode = (cachedResponse.statusCode >= 200) ? cachedResponse.statusCode : 200
                let headers = Array(cachedResponse.headerFields)
                httpResponse = HTTPURLResponse(url: url,
                                               statusCode: statusCode,
                                               httpVersion: "HTTP/1.1",
                                               headerFields: ResponseHeaderItem.deSerialize(headerItems: headers))
            case .mimeTypeAndEncoding:
                httpResponse = HTTPURLResponse(url: url,
                                               mimeType: cachedResponse.mimeType,
                                               expectedContentLength: cachedResponse.expectedContentLength,
                                               textEncodingName: cachedResponse.encoding)
            }

            guard let spoofedResponse = httpResponse else {
                if #available(iOS 12.0, *) {
                    os_log(.debug, log: Log.replayer, "⚠️ Unable to serialize response: %s", urlString)
                }
                postNotification("⚠️ Unable to serialize response: \(urlString)", object: self)
                // Throw an error in case we are unable to serialize a response
                client?.urlProtocol(self, didFailWithError: httpError)
                return
            }

            if #available(iOS 12.0, *) {
                os_log(.debug, log: Log.replayer, "💾 Serving response from: %s", urlString)
            }
            postNotification("💾 Serving response from: \(urlString)", object: self)

            client?.urlProtocol(self, didReceive: spoofedResponse, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: cachedResponse.data)
            client?.urlProtocolDidFinishLoading(self)

        case .failure:
            if #available(iOS 12.0, *) {
                os_log(.debug, log: Log.replayer, "⚠️ Database read failure: %s", urlString)
            }
            postNotification("⚠️ Database read failure: \(urlString)", object: self)
            // Throw an error in case we are unable to load a response
            client?.urlProtocol(self, didFailWithError: httpError)
        }
    }

    public override func stopLoading() {
        // Nothing to do here for replay
    }
}
