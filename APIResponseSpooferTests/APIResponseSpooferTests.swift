//
//  APIResponseSpooferTests.swift
//  APIResponseSpooferTests
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import XCTest
import UIKit

@testable import APIResponseSpoofer

class APIResponseSpooferTests: XCTestCase {
    
    var responseReceived: XCTestExpectation?
    var spoofedResponseReceived: XCTestExpectation?
    
    let smokeTest = "Smoke Test Spoofer"
    let sampleURL1 = NSURL(string: "http://echo.jsontest.com/key/value/one/two")!
    let sampleURL2 = NSURL(string: "http://jsonplaceholder.typicode.com/users")!
    let complexURL = NSURL(string: "http://www.example.com:8042/over/there/index.html?class=vehicle&type=2wheeler&name=ferrari#red")!
    
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
        responseReceived = expectationWithDescription("ResponseReceived")
        
        // 2: Start recording responses
        Spoofer.startRecording(scenarioName: smokeTest)
        
        // 3: Fetch some data using a URL session
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(sampleURL1, completionHandler: { data, response, error in
            if error == nil {
                Spoofer.stopRecording()
                self.responseReceived?.fulfill()
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
            XCTAssertTrue(smokeScenario.name == smokeTest, "Smoke test scenario was not loaded correctly")
        } else {
            XCTFail("Smoke test scenario was not loaded")
        }
        // 3: Stop the replay
        Spoofer.stopReplaying()
    }
    
    func test03SpooferReplay() {
        // 1: Create an expectation which will be fulfilled when we receive data
        spoofedResponseReceived = expectationWithDescription("SpoofedResponseReceived")
        
        // 2: Start replaying the smoke test scenario so that Spoofer can send data back instead of a direct network call
        Spoofer.startReplaying(scenarioName: smokeTest)
        
        // 3: Fetch some data using a URL session
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(sampleURL1, completionHandler: { data, response, error in
            if error == nil {
                print("Cached Response : \(response) \nCached Data: \(data)")
                Spoofer.stopReplaying()
                self.spoofedResponseReceived?.fulfill()
            }
        }).resume()
        
        // 4: Loop until the expectation is fulfilled
        waitForExpectationsWithTimeout(10, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func test04SimpleURLNormalization() {
        Spoofer.normalizeQueryParameters = true
        let normalizedSmokeURL = "echo.jsontest.com/key/value/one/two"
        XCTAssertTrue(sampleURL1.normalizedURLString == normalizedSmokeURL, "Normalized version has to have the host and query parameters values stipped away")
    }
    
    func test05ComplexURLNormalization() {
        Spoofer.normalizeQueryParameters = true
        let normalizedComplexURL = "example.com:8042/over/there/index.html?class&type&name"
        XCTAssertTrue(complexURL.normalizedURLString == normalizedComplexURL, "Normalized version must match")
    }
    
    func test06NoURLNormalization() {
        Spoofer.normalizeQueryParameters = false
        guard let normalized = complexURL.normalizedURLString else {
            XCTFail("Normalization failed")
            return
        }
        XCTAssertTrue(complexURL.absoluteString.containsString(normalized), "Non Normalized version must match original version")
    }
    
    func test07ParameterIgnoreURLNormalization() {
        Spoofer.normalizeQueryParameters = true
        Spoofer.queryParametersToIgnore = ["class","name","somerandom"]
        let normalizedComplexURLIgnoringParameters = "example.com:8042/over/there/index.html?type"
        XCTAssertTrue(complexURL.normalizedURLString == normalizedComplexURLIgnoringParameters, "Normalized version must match & must ignore specified params")
    }
    
    func test08LoadAllScenarios() {
        let allScenarios = Store.allScenarioNames()
        print("All Scenarios:\n\(allScenarios)")
    }
    
    func testFormattedSeperator() {
        logFormattedSeperator("Scenario Loaded Succesfully 👍")
        logFormattedSeperator("")
        logFormattedSeperator("-")
        logFormattedSeperator("+")
        logFormattedSeperator("@")
        logFormattedSeperator("This string is 100 characters plus to that it breaks the formated seperator logic. Yes. Break the logic. That's the test. The method should just print this string as it is.")
    }

}
