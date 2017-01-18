//
//  ResponseHeaderItem.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/2/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

class ResponseHeaderItem: Object {

    dynamic var key = ""
    dynamic var value = ""

    class func serialize(fromArray: [AnyHashable: Any]) -> [ResponseHeaderItem] {
        let headerItems = fromArray.map { key, value -> ResponseHeaderItem? in
            guard let stringKey = key as? String, let stringValue = value as? String else { return nil }
            let headerItem = ResponseHeaderItem()
            headerItem.key = stringKey
            headerItem.value = stringValue
            return headerItem
        }
        return headerItems.flatMap { $0 }
    }

    class func deSerialize(headerItems: [ResponseHeaderItem]) -> [String: String] {
        var resultDict = [String: String]()
        for item in headerItems {
            resultDict[item.key] = item.value
        }
        return resultDict
    }
}
