//
//  APIResponse.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/29/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

enum ResponseKeys: String {
    case requestURL
    case httpMethod
    case data
    case createdDate
    case mimeType
    case encoding
    case headerFields
}

class APIResponse: NSObject, NSCoding {
    
    let requestURL: NSURL
    let httpMethod: String
    let data: NSData
    let createdDate: NSDate
    let mimeType: String?
    let encoding: String?
    let headerFields: [String: String]?
    
    // Designated initializer
    init?(requestURL: NSURL, httpMethod: String, data: NSData, mimeType: String?, encoding: String?, headerFields: [String: String]?) {
        self.requestURL = requestURL
        self.httpMethod = httpMethod
        self.data = data
        self.createdDate = NSDate()
        self.mimeType = mimeType
        self.encoding = encoding
        self.headerFields = headerFields
    }
    
    convenience init?(httpRequest: NSURLRequest, httpResponse: NSURLResponse, data: NSData?) {
        guard let httpURLResponse = httpResponse as? NSHTTPURLResponse,
            url = httpRequest.URL,
            method = httpRequest.HTTPMethod,
            data = data
        else { return nil }
        
        self.init(requestURL: url, httpMethod: method, data: data, mimeType: httpResponse.MIMEType, encoding: httpResponse.textEncodingName, headerFields: httpURLResponse.allHeaderFields as? [String: String])
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        requestURL = aDecoder.decodeObjectForKey(ResponseKeys.requestURL.rawValue) as! NSURL
        httpMethod = aDecoder.decodeObjectForKey(ResponseKeys.httpMethod.rawValue) as! String
        data = aDecoder.decodeObjectForKey(ResponseKeys.data.rawValue) as! NSData
        createdDate = aDecoder.decodeObjectForKey(ResponseKeys.createdDate.rawValue) as! NSDate
        mimeType = aDecoder.decodeObjectForKey(ResponseKeys.mimeType.rawValue) as? String
        encoding = aDecoder.decodeObjectForKey(ResponseKeys.encoding.rawValue) as? String
        headerFields = aDecoder.decodeObjectForKey(ResponseKeys.encoding.rawValue) as? [String : String]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(requestURL, forKey: ResponseKeys.requestURL.rawValue)
        aCoder.encodeObject(httpMethod, forKey: ResponseKeys.httpMethod.rawValue)
        aCoder.encodeObject(data, forKey: ResponseKeys.data.rawValue)
        aCoder.encodeObject(createdDate, forKey: ResponseKeys.createdDate.rawValue)
        aCoder.encodeObject(mimeType, forKey: ResponseKeys.mimeType.rawValue)
        aCoder.encodeObject(encoding, forKey: ResponseKeys.encoding.rawValue)
        aCoder.encodeObject(headerFields, forKey: ResponseKeys.headerFields.rawValue)
    }
    
    // MARK: - Equatable
    
    override func isEqual(object: AnyObject?) -> Bool {
        guard let rhs = object as? APIResponse else { return false }
        guard let lhsURL = requestURL.normalizedURLString, rhsURL = rhs.requestURL.normalizedURLString else { return false }
        if lhsURL == rhsURL {
            return true
        }
        return false
    }
    
}

// MARK: - Helper methods for debugging

extension APIResponse: CustomDebugStringConvertible {
    override var description: String { return "URL: \(requestURL)\nMethod: \(httpMethod)"}
    override var debugDescription: String { return "URL: \(requestURL)\nMethod: \(httpMethod)\nCreatedDate: \(createdDate)\nMIMEType: \(mimeType)\nEncoding: \(encoding)\n"}
}
