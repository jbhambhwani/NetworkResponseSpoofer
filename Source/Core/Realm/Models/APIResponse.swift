//
//  APIResponse.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/26/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

class APIResponse: Object {

    dynamic var requestURL = ""
    dynamic var httpMethod = ""
    dynamic var statusCode = 0
    dynamic var createdDate = Date()
    dynamic var mimeType: String?
    dynamic var encoding: String?
    dynamic var expectedContentLength = 0
    let headerFields = List<ResponseHeaderItem>()

    /* IMPORTANT: README
     We run the received data through JSONSerialization, and if its JSON Convertible, save it under jsonRepresentation variable, and if not under backkupData. This allows JSON responses to be edited if needed using RealmBrowser. In case serialization fails, the data is saved as is under 'backupData'. This would be the fallback for any response object which is not JSON type.

     While serving the response back, first the jsonRepresentation field is checked, and data will be constructed if available. Else backupData is served back.
     */
    dynamic var data: Data {
        get {
            guard jsonRepresentation.isEmpty == false, let dataFromString = jsonRepresentation.data(using: .utf8) else {
                return backupData ?? Data()
            }
            return dataFromString
        }

        set {
            guard let dataAsString = String(data: newValue, encoding: .utf8) else {
                backupData = newValue
                return
            }
            jsonRepresentation = dataAsString
        }
    }

    dynamic var backupData: Data?
    dynamic var jsonRepresentation = ""

    override static func ignoredProperties() -> [String] {
        return ["data"]
    }
}

// MARK: -

extension APIResponse {

    class func responseFrom(httpRequest: URLRequest, httpResponse: URLResponse, data: Data?) -> APIResponse? {
        guard let httpURLResponse = httpResponse as? HTTPURLResponse,
            let url = httpRequest.url,
            let method = httpRequest.httpMethod,
            let data = data
        else { return nil }

        let headerFields = httpURLResponse.allHeaderFields
        let mimeType = httpURLResponse.mimeType
        let encoding = httpURLResponse.textEncodingName
        let contentLength = NSInteger(httpURLResponse.expectedContentLength)
        let statusCode = NSInteger(httpURLResponse.statusCode)

        let response = APIResponse()
        response.requestURL = url.absoluteString.lowercased()
        response.httpMethod = method
        response.statusCode = statusCode
        response.mimeType = mimeType
        response.encoding = encoding
        response.headerFields.append(objectsIn: ResponseHeaderItem.serialize(fromArray: headerFields))
        response.expectedContentLength = contentLength
        response.data = data

        return response
    }
}

// MARK: - Equatable

extension APIResponse {

    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? APIResponse,
            let lhsURL = URL(string: requestURL),
            let rhsURL = URL(string: rhs.requestURL) else { return false }

        if lhsURL.normalizedString == rhsURL.normalizedString {
            return true
        }
        return false
    }

    override var hashValue: Int {
        return requestURL.hashValue ^ httpMethod.hashValue ^ data.hashValue
    }
}

// MARK: - Helper methods for debugging

extension APIResponse {
    override var description: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)" }
    override var debugDescription: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)\nCreatedDate: \(createdDate)\nMIMEType: \(String(describing: mimeType))\nEncoding: \(String(describing: encoding))\nHeaderFields: \(headerFields)\n" }
}
