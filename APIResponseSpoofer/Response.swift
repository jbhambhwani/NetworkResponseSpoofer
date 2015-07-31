//
//  Response.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 7/29/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import Foundation

class Response : NSObject, NSCoding {
    
    let requestURL: String
    let method: String
    let data: NSData?
    let createdDate: NSDate
    let mimeType: String?
    let encoding: String?
    
    init?(requestURL: String, method: String, data: NSData?, mimeType: String?, encoding: String?) {
        self.requestURL = requestURL
        self.method = method
        self.data = data
        self.createdDate = NSDate()
        self.mimeType = mimeType
        self.encoding = encoding
    }
    
    // MARK: NSCoding
    required init(coder aDecoder: NSCoder) {
        requestURL = aDecoder.decodeObjectForKey("requestURL") as! String
        method = aDecoder.decodeObjectForKey("method") as! String
        data = aDecoder.decodeObjectForKey("data") as? NSData
        createdDate = aDecoder.decodeObjectForKey("createdDate") as! NSDate
        mimeType = aDecoder.decodeObjectForKey("mimeType") as? String
        encoding = aDecoder.decodeObjectForKey("encoding") as? String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(requestURL, forKey: "requestURL")
        aCoder.encodeObject(method, forKey: "method")
        aCoder.encodeObject(data, forKey: "data")
        aCoder.encodeObject(createdDate, forKey: "createdDate")
        aCoder.encodeObject(mimeType, forKey: "mimeType")
        aCoder.encodeObject(encoding, forKey: "encoding")
    }
    
}

// MARK: Helper methods for debugging
extension Response: DebugPrintable, Printable {
    override var description: String { return "URL:\(requestURL)"}
    override var debugDescription: String { return " URL: \(requestURL)\n Method: \(method)\n CreatedDate: \(createdDate)\n"}
}