//
//  APIResponseV2.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/26/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

class APIResponseV2: Object {

    dynamic var requestURL = ""
    dynamic var httpMethod = ""
    dynamic var statusCode = 0
    dynamic var data = Data()
    dynamic var createdDate = Date()
    dynamic var mimeType: String?
    dynamic var encoding: String?
    dynamic var expectedContentLength = 0
    let headerFields = List<ResponseHeaderItem>()
    
    class func responseFrom(httpRequest: URLRequest, httpResponse: URLResponse, data: Data?) -> APIResponseV2? {
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
        
        let response = APIResponseV2()
        response.requestURL = url.absoluteString
        response.httpMethod = method
        response.statusCode = statusCode
        response.data = data
        response.mimeType = mimeType
        response.encoding = encoding
        response.headerFields.append(objectsIn: ResponseHeaderItem.serialize(fromArray: headerFields))
        response.expectedContentLength = contentLength
        
        return response
    }
}

extension APIResponseV2 {
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? APIResponseV2 else { return false }
        
        //TODO
        let lhsURL = ""
        let rhsURL = ""
        
        // guard let lhsURL = requestURL.normalizedURLString, let rhsURL = rhs.requestURL.normalizedURLString else { return false }
        if lhsURL == rhsURL {
            return true
        }
        return false
    }
    
    override var hashValue: Int {
        return requestURL.hashValue ^ httpMethod.hashValue ^ data.hashValue
    }
    
}


// MARK: - Helper methods for debugging

extension APIResponseV2 {
    override var description: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)"}
    override var debugDescription: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)\nCreatedDate: \(createdDate)\nMIMEType: \(mimeType)\nEncoding: \(encoding)\nHeaderFields: \(headerFields)\n"}
}
