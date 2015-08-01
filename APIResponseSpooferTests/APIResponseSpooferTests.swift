//
//  APIResponseSpooferTests.swift
//  APIResponseSpooferTests
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import UIKit
import XCTest
import APIResponseSpoofer

class APIResponseSpooferTests: XCTestCase {
    
    var readyExpectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSpooferProtocol() {
        
        // 1: Create an expectation which will be fulfilled when we receive data
        readyExpectation = expectationWithDescription("ResponseReceived")
        
        // 2: Start recording responses
        Spoofer.startRecording(scenarioName: "Smoke Test Spoofer")
        
        // 3: Fetch some data using a URL session
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "http://echo.jsontest.com/key/value/one/two")
        session.dataTaskWithURL(url!, completionHandler: { data, response, error in
            if error == nil {
                Spoofer.stopRecording()
                self.readyExpectation?.fulfill()
            }
        }).resume()
        
        // 4: Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(10, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
}
