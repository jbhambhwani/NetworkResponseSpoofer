//
//  NetworkResponse.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 10/26/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class NetworkResponse: Object {
    @objc public dynamic var requestURL = ""
    @objc public dynamic var requestQueryParams: String? = ""
    @objc public dynamic var requestHeaders: String? = ""
    @objc public dynamic var requestBody: String? = ""
    @objc public dynamic var responseHeaders: String? = ""
    @objc public dynamic var responseBody: String? = ""
    @objc public dynamic var httpMethod = ""
    @objc public dynamic var statusCode = 0
    @objc public dynamic var createdDate = Date()
    @objc public dynamic var mimeType: String?
    @objc public dynamic var encoding: String?
    @objc public dynamic var expectedContentLength = 0
    @objc public dynamic var servedToClient = false
    public let headerFields = List<ResponseHeaderItem>()

    /* IMPORTANT: README
     We run the received data through JSONSerialization, and if its JSON Convertible, save it under jsonRepresentation variable,
     and if not under backupData. This allows JSON responses to be edited if needed using RealmBrowser.
     In case serialization fails, the data is saved as is under 'backupData'.
     This would be the fallback for any response object which is not JSON type.

     While serving the response back, first the jsonRepresentation field is checked,
     and data will be constructed if available. Else backupData is served back.
     */
    @objc public dynamic var data: Data {
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

    @objc dynamic var backupData: Data?
    @objc dynamic var jsonRepresentation = ""

    public override static func ignoredProperties() -> [String] {
        return ["data"]
    }
}

// MARK: -

extension NetworkResponse {
    class func responseFrom(httpRequest: URLRequest, httpResponse: URLResponse, requestData: Data?, responseData: Data?) -> NetworkResponse? {
        guard let httpURLResponse = httpResponse as? HTTPURLResponse,
            let url = httpRequest.url,
            let method = httpRequest.httpMethod,
            let data = responseData
        else { return nil }

        let headerFields = httpURLResponse.allHeaderFields
        let mimeType = httpURLResponse.mimeType
        let encoding = httpURLResponse.textEncodingName
        let contentLength = NSInteger(httpURLResponse.expectedContentLength)
        let statusCode = NSInteger(httpURLResponse.statusCode)

        let response = NetworkResponse()
        response.requestURL = url.absoluteString.lowercased()
        response.requestQueryParams = url.query
        response.requestHeaders = httpRequest.allHTTPHeaderFields?.reduce(into: "") {
                $0 = $0 + "\($1.key) \($1.value)"
            }
        response.requestBody = String(data: httpRequest.httpBody ?? requestData ?? Data(), encoding: .utf8)
        
        response.responseHeaders = httpURLResponse.allHeaderFields.reduce(into: "") {
                $0 = $0 + "\($1.key) \($1.value)"
        }
        response.responseBody = String(data: data, encoding: .utf8)
        
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

extension NetworkResponse {
    public override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? NetworkResponse,
            let lhsURL = URL(string: requestURL),
            let rhsURL = URL(string: rhs.requestURL) else { return false }

        if lhsURL.normalizedString == rhsURL.normalizedString {
            return true
        }
        return false
    }

    public override var hash: Int {
        return requestURL.hashValue ^ httpMethod.hashValue ^ data.hashValue
    }
}

// MARK: - Helper methods for debugging

extension NetworkResponse {
    public override var description: String { return """
    URL: \(requestURL)
    Method: \(httpMethod)
    StatusCode: \(statusCode)
    """
    }

    public override var debugDescription: String { return """
    URL: \(requestURL)
    Method: \(httpMethod)
    StatusCode: \(statusCode)
    CreatedDate: \(createdDate)
    MIMEType: \(String(describing: mimeType))
    Encoding: \(String(describing: encoding))
    HeaderFields: \(headerFields)
    """
    }
}
