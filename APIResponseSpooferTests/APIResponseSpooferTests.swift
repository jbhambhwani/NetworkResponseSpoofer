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
    let smokeTest = "Smoke Test Spoofer"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSpooferRecord() {

        // 1: Create an expectation which will be fulfilled when we receive data
        readyExpectation = expectationWithDescription("ResponseReceived")

        // 2: Start recording responses
        Spoofer.startRecording(scenarioName: smokeTest)

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
    
    func testSpooferReplay() {
        
        // 1: Start replaying the smoke test scenario
        Spoofer.startReplaying(scenarioName: smokeTest)
        // 2: Make sure the scenario was loaded to spoofer
        if let smokeScenario = Spoofer.spoofedScenario {
            assert(smokeScenario.name == smokeTest, "Smoke test scenario was not loaded correctly")
        } else {
            assert(false, "Smoke test scenario was not loaded")
        }
        // 3: Stop the replay
        Spoofer.stopReplaying()
    }
    
}
