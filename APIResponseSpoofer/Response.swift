//
//  Response.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/29/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

struct ResponseFields {
    static let requestURL = "requestURL"
    static let httpMethod = "httpMethod"
    static let data = "data"
    static let createdDate = "createdDate"
    static let mimeType = "mimeType"
    static let encoding = "encoding"
}

class Response : NSObject, NSCoding {
    
    let requestURL: String
    let httpMethod: String
    let data: NSData?
    let createdDate: NSDate
    let mimeType: String?
    let encoding: String?
    
    // Designated initializer
    init?(requestURL: String, httpMethod: String, data: NSData?, mimeType: String?, encoding: String?) {
        self.requestURL = requestURL
        self.httpMethod = httpMethod
        self.data = data
        self.createdDate = NSDate()
        self.mimeType = mimeType
        self.encoding = encoding
    }
    
    convenience init?(httpRequest: NSURLRequest, httpResponse: NSURLResponse, data: NSData?) {
        self.init(requestURL: httpRequest.URL!.absoluteString!, httpMethod:httpRequest.HTTPMethod!, data: data!, mimeType: httpResponse.MIMEType, encoding: httpResponse.textEncodingName)
    }
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        requestURL = aDecoder.decodeObjectForKey(ResponseFields.requestURL) as! String
        httpMethod = aDecoder.decodeObjectForKey(ResponseFields.httpMethod) as! String
        data = aDecoder.decodeObjectForKey(ResponseFields.data) as? NSData
        createdDate = aDecoder.decodeObjectForKey(ResponseFields.createdDate) as! NSDate
        mimeType = aDecoder.decodeObjectForKey(ResponseFields.mimeType) as? String
        encoding = aDecoder.decodeObjectForKey(ResponseFields.encoding) as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(requestURL, forKey: ResponseFields.requestURL)
        aCoder.encodeObject(httpMethod, forKey: ResponseFields.httpMethod)
        aCoder.encodeObject(data, forKey: ResponseFields.data)
        aCoder.encodeObject(createdDate, forKey: ResponseFields.createdDate)
        aCoder.encodeObject(mimeType, forKey: ResponseFields.mimeType)
        aCoder.encodeObject(encoding, forKey: ResponseFields.encoding)
    }
    
}

// MARK: Helper methods for debugging
extension Response: DebugPrintable, Printable {
    override var description: String { return " URL: \(requestURL)\n Method: \(httpMethod)"}
    override var debugDescription: String { return " URL: \(requestURL)\n Method: \(httpMethod)\n CreatedDate: \(createdDate)\n MIMEType: \(mimeType)\n Encoding: \(encoding)\n"}
}