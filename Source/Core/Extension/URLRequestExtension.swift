//
//  URLRequestExtension.swift
//  NetworkResponseSpoofer
//
//  Created by Jaikumar Bhambhwani on 24/06/2020.
//

import Foundation

extension URLRequest {

    var httpJSONBodyStream: Data? {

        guard let bodyStream = self.httpBodyStream else { return nil }

        bodyStream.open()

        // Will read 16 chars per iteration. Can use bigger buffer if needed
        let bufferSize: Int = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var dat = Data()

        while bodyStream.hasBytesAvailable {
            let readDat = bodyStream.read(buffer, maxLength: bufferSize)
            dat.append(buffer, count: readDat)
        }

        buffer.deallocate()
        bodyStream.close()

        return dat
    }
}
