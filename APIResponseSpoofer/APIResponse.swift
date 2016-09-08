//
//  APIResponse.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/29/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

private enum ResponseKeys: String {
    case requestURL
    case httpMethod
    case statusCode
    case data
    case createdDate
    case mimeType
    case encoding
    case headerFields
    case expectedContentLength
}

class APIResponse: NSObject, NSCoding {
    
    let requestURL: URL
    let httpMethod: String
    let statusCode: NSInteger
    let data: Data
    let createdDate: Date
    let mimeType: String?
    let encoding: String?
    let headerFields: [NSObject : AnyObject]?
    let expectedContentLength: NSInteger
    
    // Designated initializer
    init?(requestURL: URL, httpMethod: String, statusCode: NSInteger, data: Data, mimeType: String?, encoding: String?, headerFields: [NSObject: AnyObject]?, expectedContentLength: NSInteger) {
        self.requestURL = requestURL
        self.httpMethod = httpMethod
        self.statusCode = statusCode
        self.data = data
        self.createdDate = Date()
        self.mimeType = mimeType
        self.encoding = encoding
        self.headerFields = headerFields
        self.expectedContentLength = expectedContentLength
    }
    
    convenience init?(httpRequest: URLRequest, httpResponse: URLResponse, data: Data?) {
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
        
        self.init(requestURL: url, httpMethod: method, statusCode: statusCode, data: data, mimeType: mimeType, encoding: encoding, headerFields: headerFields, expectedContentLength: contentLength)
    }

    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        requestURL = aDecoder.decodeObject(forKey: ResponseKeys.requestURL.rawValue) as! URL
        httpMethod = aDecoder.decodeObject(forKey: ResponseKeys.httpMethod.rawValue) as! String
        statusCode = aDecoder.decodeInteger(forKey: ResponseKeys.statusCode.rawValue)
        data = aDecoder.decodeObject(forKey: ResponseKeys.data.rawValue) as! Data
        createdDate = aDecoder.decodeObject(forKey: ResponseKeys.createdDate.rawValue) as! Date
        mimeType = aDecoder.decodeObject(forKey: ResponseKeys.mimeType.rawValue) as? String
        encoding = aDecoder.decodeObject(forKey: ResponseKeys.encoding.rawValue) as? String
        headerFields = aDecoder.decodeObject(forKey: ResponseKeys.headerFields.rawValue) as? [NSObject: AnyObject]
        expectedContentLength = aDecoder.decodeInteger(forKey: ResponseKeys.expectedContentLength.rawValue)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(requestURL, forKey: ResponseKeys.requestURL.rawValue)
        aCoder.encode(httpMethod, forKey: ResponseKeys.httpMethod.rawValue)
        aCoder.encode(statusCode, forKey: ResponseKeys.statusCode.rawValue)
        aCoder.encode(data, forKey: ResponseKeys.data.rawValue)
        aCoder.encode(createdDate, forKey: ResponseKeys.createdDate.rawValue)
        aCoder.encode(mimeType, forKey: ResponseKeys.mimeType.rawValue)
        aCoder.encode(encoding, forKey: ResponseKeys.encoding.rawValue)
        aCoder.encode(headerFields, forKey: ResponseKeys.headerFields.rawValue)
        aCoder.encode(expectedContentLength, forKey: ResponseKeys.expectedContentLength.rawValue)
    }

}

// MARK: - NSCoding

extension APIResponse {
    
    override func isEqual(_ object: AnyObject?) -> Bool {
        guard let rhs = object as? APIResponse else { return false }
        guard let lhsURL = requestURL.normalizedURLString, let rhsURL = rhs.requestURL.normalizedURLString else { return false }
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

extension APIResponse {
    override var description: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)"}
    override var debugDescription: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)\nCreatedDate: \(createdDate)\nMIMEType: \(mimeType)\nEncoding: \(encoding)\nHeaderFields: \(headerFields)\n"}
}
