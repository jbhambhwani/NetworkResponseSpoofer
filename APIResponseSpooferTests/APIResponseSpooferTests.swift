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
    let smokeURL = NSURL(string: "http://echo.jsontest.com/key/value/one/two")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test01SpooferRecord() {
        
        // 1: Create an expectation which will be fulfilled when we receive data
        readyExpectation = expectationWithDescription("ResponseReceived")
        
        // 2: Start recording responses
        Spoofer.startRecording(scenarioName: smokeTest)
        
        // 3: Fetch some data using a URL session
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(smokeURL, completionHandler: { data, response, error in
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
    
    func test02SpooferPersistence() {
        
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
    
    func test03SpooferReplay() {
        
        // 1: Create an expectation which will be fulfilled when we receive data
        readyExpectation = expectationWithDescription("SpoofedResponseReceived")
        
        // 2: Start replaying the smoke test scenario so that Spoofer can send data back instead of a direct network call
        Spoofer.startReplaying(scenarioName: smokeTest)
        
        // 3: Fetch some data using a URL session
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(smokeURL, completionHandler: { data, response, error in
            if error == nil {
                println("Cached Response : \(response) \nCached Data: \(data)")
                Spoofer.stopReplaying()
                self.readyExpectation?.fulfill()
            }
        }).resume()

        // 4: Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(10, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func test04URLNormalization() {
        let normalizedSmokeURL = "echo.jsontest.com/key/value/one/two"
        assert(smokeURL.normalizedURLString == normalizedSmokeURL, "Normalized version has to have the host and query parameters values stipped away")

        // TODO: Uncomment after fixing URL Normalization code
//        let complexURL = NSURL(string: "http://www.example.com:8042/over/there/index.html?type=animal&name=cat#nose")
//        let normalizedComplexURL = "www.example.com/over/there/index.html?type&name"
//        assert(complexURL!.normalizedURLString == normalizedComplexURL, "Normalized version has to have the host and query parameters values stipped away")
    }
    
    func test05LoadAllScenarios() {
        let allScenarios = Store.allScenarios()
        println("All Scenarios:\n\(allScenarios)")
    }
    
}
