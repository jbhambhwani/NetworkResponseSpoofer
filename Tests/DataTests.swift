//
//  DataTests.swift
//  NetworkResponseSpooferTests
//
//  Created by Deepu Mukundan on 7/28/15.
//  Copyright (c) 2015 Hotwire. All rights reserved.
//

@testable import NetworkResponseSpoofer
import RealmSwift
import XCTest

final class DataTests: XCTestCase {
    var responseReceived: XCTestExpectation?
    var spoofedResponseReceived: XCTestExpectation?

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.
        Spoofer.resetConfigurations()
    }

    func test01SpooferRecord() {
        // 1: Create an expectation which will be fulfilled when we receive data
        responseReceived = expectation(description: "ResponseReceived")

        // 2: Start recording responses
        Spoofer.startRecording(scenarioName: smokeTest)

        // 3: Fetch some data using a URL session
        let session = URLSession(configuration: URLSessionConfiguration.spoofedDefault())
        session.dataTask(with: sampleURL1, completionHandler: { [weak self] _, _, error in
            if error == nil {
                self?.responseReceived?.fulfill()
                Spoofer.stopRecording()
            }
        }).resume()

        // 4: Loop until the expectation is fulfilled
        waitForExpectations(timeout: 10, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

    func test02SpooferReplay() {
        // 1: Create an expectation which will be fulfilled when we receive data
        spoofedResponseReceived = expectation(description: "SpoofedResponseReceived")

        // 2: Start replaying the smoke test scenario so that Spoofer can send data back instead of a direct network call
        Spoofer.startReplaying(scenarioName: smokeTest)

        // 3: Fetch some data using a URL session
        let session = URLSession(configuration: URLSessionConfiguration.spoofedDefault())

        session.dataTask(with: sampleURL1, completionHandler: { [weak self] data, response, error in
            if error == nil, let response = response, let data = data {
                print("Cached Response : \(response) \nCached Data: \(data)")
                self?.spoofedResponseReceived?.fulfill()
                Spoofer.stopReplaying()
            }
        }).resume()

        // 4: Loop until the expectation is fulfilled
        waitForExpectations(timeout: 10, handler: { error in
            XCTAssertNil(error, "Error")
        })
    }

    func test03SpooferPersistence() {
        // 1: Start replaying the smoke test scenario
        Spoofer.startReplaying(scenarioName: smokeTest)
        // 2: Make sure the scenario was loaded to spoofer
        if Spoofer.scenarioName.isEmpty == false {
            XCTAssertTrue(Spoofer.scenarioName == smokeTest, "Smoke test scenario was not loaded correctly")

            let loadResult = DataStore.load(scenarioName: smokeTest, suite: defaultSuiteName)
            switch loadResult {
            case let .success(scenario):
                guard let responseData = scenario.networkResponses.first?.data else {
                    XCTFail("No data was found on smoke test scenario")
                    return
                }
                let responseDict: [String: String]? =
                    try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: String]

                guard let json = responseDict,
                    json == ["one": "two", "key": "value"] else {
                    XCTFail("Replayed respose not same as Recorded")
                    return
                }

            case .failure: break
            }

        } else {
            XCTFail("Smoke test scenario was not loaded")
        }

        Spoofer.stopReplaying()
    }

    func test04LoadAllScenarios() {
        let allScenarios = DataStore.allScenarioNames(suite: defaultSuiteName)
        print("All Scenarios:\n\(allScenarios)")
        XCTAssert(allScenarios.count > 0, "Stored scenarios should be loaded")
    }
}
