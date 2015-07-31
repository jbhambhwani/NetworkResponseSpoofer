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

class APIResponseSpooferTests: XCTestCase, NSURLConnectionDataDelegate {
    
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
        
        // Create an expectation which will be fulfilled when we receive data
        readyExpectation = expectationWithDescription("ResponseReceived")
        
        // Start recording responses
        Spoofer.startRecording(scenario: Scenario())
        
        // Fetch some data using a URL session
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "http://echo.jsontest.com/key/value/one/two")
        session.dataTaskWithURL(url!, completionHandler: { data, response, error in
            if error == nil {
                Spoofer.stopRecording()
                self.readyExpectation?.fulfill()
            }
        }).resume()
        
        // Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
}
