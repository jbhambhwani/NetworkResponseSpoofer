//
//  APIResponseSpooferTests.swift
//  APIResponseSpooferTests
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

import XCTest
import UIKit
import RealmSwift

@testable import APIResponseSpoofer

class APIResponseSpooferTests: XCTestCase {
    
    var responseReceived: XCTestExpectation?
    var spoofedResponseReceived: XCTestExpectation?
    
    let smokeTest = "Smoke Test Spoofer"
    let sampleURL1 = URL(string: "http://echo.jsontest.com/key/value/one/two")!
    let sampleURL2 = URL(string: "http://jsonplaceholder.typicode.com/users")!
    let allCapsURL = URL(string: "HTTP://JSONPLACEHOLDER.TYPICODE.COM/USERS")!
    let complexURL = URL(string: "http://www.example.com:8042/over/there/index.html?class=vehicle&type=2wheeler&name=ferrari#red")!
    
    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        URLSessionConfiguration.swizzleConfiguration()
        Spoofer.resetConfigurations()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test01SpooferRecord() {
        // 1: Create an expectation which will be fulfilled when we receive data
        responseReceived = expectation(description: "ResponseReceived")
        
        // 2: Start recording responses
        Spoofer.startRecording(scenarioName: smokeTest)
        
        // 3: Fetch some data using a URL session
        let session = URLSession(configuration: URLSessionConfiguration.spoofed)
        session.dataTask(with: sampleURL1, completionHandler: { [weak self] data, response, error in
            if error == nil {
                Spoofer.stopRecording()
                self?.responseReceived?.fulfill()
            }
        }).resume()
        
        // 4: Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func test02SpooferPersistence() {
        // 1: Start replaying the smoke test scenario
        Spoofer.startReplaying(scenarioName: smokeTest)
        // 2: Make sure the scenario was loaded to spoofer
        if Spoofer.scenarioName.isEmpty == false {
            XCTAssertTrue(Spoofer.scenarioName == smokeTest, "Smoke test scenario was not loaded correctly")
            
            let loadResult = DataStore.load(scenarioName: smokeTest)
            switch loadResult {
            case .success(let scenario):
                guard let responseData = scenario.apiResponses.first?.data else {
                    XCTFail("No data was found on smoke test scenario")
                    return
                }
                let responseDict: [String: String]? = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as! [String : String]
                
                guard let json = responseDict, json == ["one": "two", "key": "value"] else {
                    XCTFail("Replayed respose not same as Recorded")
                    return
                }
        
            case .failure(_): break
            }

        } else {
            XCTFail("Smoke test scenario was not loaded")
        }
        // 3: Stop the replay
        Spoofer.stopReplaying()
    }
    
    func test03SpooferReplay() {
        // 1: Create an expectation which will be fulfilled when we receive data
        spoofedResponseReceived = expectation(description: "SpoofedResponseReceived")
        
        // 2: Start replaying the smoke test scenario so that Spoofer can send data back instead of a direct network call
        Spoofer.startReplaying(scenarioName: smokeTest)
        
        // 3: Fetch some data using a URL session
        let config = URLSessionConfiguration.spoofed
        let session = URLSession(configuration: config)

        session.dataTask(with: sampleURL1, completionHandler: { [weak self] data, response, error in
            if error == nil, let response = response, let data = data {
                print("Cached Response : \(response) \nCached Data: \(data)")
                Spoofer.stopReplaying()
                self?.spoofedResponseReceived?.fulfill()
            }
        }).resume()
        
        // 4: Loop until the expectation is fulfilled
        waitForExpectations(timeout: 5, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }
    
    func test04SimpleURLNormalization() {
        Spoofer.normalizeQueryValues = true
        let normalizedSmokeURL = "echo.jsontest.com/key/value/one/two"
        XCTAssertTrue(sampleURL1.normalizedURLString == normalizedSmokeURL, "Normalized version has to have the host and query parameters values stipped away")
    }
    
    func test05ComplexURLNormalization() {
        Spoofer.normalizeQueryValues = true
        let normalizedComplexURL = "example.com:8042/over/there/index.html?class&type&name#red"
        XCTAssertTrue(complexURL.normalizedURLString == normalizedComplexURL, "Normalized version must match")
    }
    
    func test06NoURLNormalization() {
        Spoofer.normalizeQueryValues = false
        guard let normalized = complexURL.normalizedURLString, normalized.characters.count > 0 else {
            XCTFail("Normalization failed")
            return
        }
        print(normalized)
        XCTAssertTrue(complexURL.absoluteString.contains(normalized), "Non Normalized version must match original version")
    }
    
    func test07ParameterIgnoreURLNormalization() {
        Spoofer.normalizeQueryValues = true
        Spoofer.queryParametersToNormalize = ["class", "name", "somerandom"]
        let normalizedComplexURLIgnoringParameters = "example.com:8042/over/there/index.html?type#red"
        XCTAssertTrue(complexURL.normalizedURLString == normalizedComplexURLIgnoringParameters, "Normalized version must match & must ignore specified params")
    }
    
    func test08CapitalURLNormalization() {
        Spoofer.normalizeQueryValues = true
        let normalizedAllCapsURL = "jsonplaceholder.typicode.com/users"
        XCTAssertTrue(allCapsURL.normalizedURLString == normalizedAllCapsURL, "After normalization, all URL's should be lower case")
    }

    func test09PathIgnoreRules() {
        Spoofer.normalizeQueryValues = true
        Spoofer.pathComponentsToNormalize = ["over", "there"]
        let normalizedPathIgnoredURL = "example.com:8042/index.html?class&type&name#red"
        XCTAssertTrue(complexURL.normalizedURLString == normalizedPathIgnoredURL, "After normalization, path componets should be ignored if specified")
    }
    
    func testLoadAllScenarios() {
        let allScenarios = DataStore.allScenarioNames()
        print("All Scenarios:\n\(allScenarios)")
        XCTAssert(allScenarios.count > 0, "Stored scenarios should be loaded")
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
