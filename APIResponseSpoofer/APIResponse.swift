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
    
    let requestURL: NSURL
    let httpMethod: String
    let statusCode: NSInteger
    let data: NSData
    let createdDate: NSDate
    let mimeType: String?
    let encoding: String?
    let headerFields: [NSObject : AnyObject]?
    let expectedContentLength: NSInteger
    
    // Designated initializer
    init?(requestURL: NSURL, httpMethod: String, statusCode: NSInteger, data: NSData, mimeType: String?, encoding: String?, headerFields: [NSObject: AnyObject]?, expectedContentLength: NSInteger) {
        self.requestURL = requestURL
        self.httpMethod = httpMethod
        self.statusCode = statusCode
        self.data = data
        self.createdDate = NSDate()
        self.mimeType = mimeType
        self.encoding = encoding
        self.headerFields = headerFields
        self.expectedContentLength = expectedContentLength
    }
    
    convenience init?(httpRequest: NSURLRequest, httpResponse: NSURLResponse, data: NSData?) {
        guard let httpURLResponse = httpResponse as? NSHTTPURLResponse,
            url = httpRequest.URL,
            method = httpRequest.HTTPMethod,
            data = data
        else { return nil }
        
        let headerFields = httpURLResponse.allHeaderFields
        let mimeType = httpURLResponse.MIMEType
        let encoding = httpURLResponse.textEncodingName
        let contentLength = NSInteger(httpURLResponse.expectedContentLength)
        let statusCode = NSInteger(httpURLResponse.statusCode)
        
        self.init(requestURL: url, httpMethod: method, statusCode: statusCode, data: data, mimeType: mimeType, encoding: encoding, headerFields: headerFields, expectedContentLength: contentLength)
    }

    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        requestURL = aDecoder.decodeObjectForKey(ResponseKeys.requestURL.rawValue) as! NSURL
        httpMethod = aDecoder.decodeObjectForKey(ResponseKeys.httpMethod.rawValue) as! String
        statusCode = aDecoder.decodeIntegerForKey(ResponseKeys.statusCode.rawValue)
        data = aDecoder.decodeObjectForKey(ResponseKeys.data.rawValue) as! NSData
        createdDate = aDecoder.decodeObjectForKey(ResponseKeys.createdDate.rawValue) as! NSDate
        mimeType = aDecoder.decodeObjectForKey(ResponseKeys.mimeType.rawValue) as? String
        encoding = aDecoder.decodeObjectForKey(ResponseKeys.encoding.rawValue) as? String
        headerFields = aDecoder.decodeObjectForKey(ResponseKeys.headerFields.rawValue) as? [NSObject: AnyObject]
        expectedContentLength = aDecoder.decodeIntegerForKey(ResponseKeys.expectedContentLength.rawValue)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(requestURL, forKey: ResponseKeys.requestURL.rawValue)
        aCoder.encodeObject(httpMethod, forKey: ResponseKeys.httpMethod.rawValue)
        aCoder.encodeInteger(statusCode, forKey: ResponseKeys.statusCode.rawValue)
        aCoder.encodeObject(data, forKey: ResponseKeys.data.rawValue)
        aCoder.encodeObject(createdDate, forKey: ResponseKeys.createdDate.rawValue)
        aCoder.encodeObject(mimeType, forKey: ResponseKeys.mimeType.rawValue)
        aCoder.encodeObject(encoding, forKey: ResponseKeys.encoding.rawValue)
        aCoder.encodeObject(headerFields, forKey: ResponseKeys.headerFields.rawValue)
        aCoder.encodeInteger(expectedContentLength, forKey: ResponseKeys.expectedContentLength.rawValue)
    }

}

// MARK: - NSCoding

extension APIResponse {
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let rhs = object as? APIResponse else { return false }
        guard let lhsURL = requestURL.normalizedURLString, rhsURL = rhs.requestURL.normalizedURLString else { return false }
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

extension APIResponse: CustomDebugStringConvertible {
    override var description: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)"}
    override var debugDescription: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nStatusCode: \(statusCode)\nCreatedDate: \(createdDate)\nMIMEType: \(mimeType)\nEncoding: \(encoding)\nHeaderFields: \(headerFields)\n"}
}
