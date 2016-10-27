//
//  Spoofer+Realm.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/26/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
#if !COCOAPODS
    import RealmSwift
#endif

class ScenarioV2: Object {
    
    dynamic var name = "Default"
    let apiResponses = List<APIResponseV2>()
}

class APIResponseV2: Object {

    dynamic var requestURL = ""
    dynamic var httpMethod = ""
    dynamic var statusCode = 0
    dynamic var data = Data()
    dynamic var createdDate = Date()
    dynamic var mimeType: String?
    dynamic var encoding: String?
    dynamic var expectedContentLength = 0
    let headerFields = List<ResponseHeader>()
}

class ResponseHeader: Object {

    dynamic var key = ""
    dynamic var value = ""
}
