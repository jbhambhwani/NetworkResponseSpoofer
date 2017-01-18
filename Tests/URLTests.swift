//
//  URLTests.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import XCTest
@testable import APIResponseSpoofer

class URLTests: XCTestCase {

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

    func testSimpleURLNormalization() {
        Spoofer.normalizeQueryValues = true
        let normalizedSmokeURL = "echo.jsontest.com/key/value/one/two"
        XCTAssertTrue(sampleURL1.normalizedString == normalizedSmokeURL, "Normalized version has to have the host and query parameters values stipped away")
    }

    func testComplexURLNormalization() {
        Spoofer.normalizeQueryValues = true
        let normalizedComplexURL = "example.com:8042/over/there/index.html?class&type&name#red"
        XCTAssertTrue(complexURL.normalizedString == normalizedComplexURL, "Normalized version must match")
    }

    func testParameterIgnoreURLNormalization() {
        Spoofer.normalizeQueryValues = true
        Spoofer.queryParametersToNormalize = ["class", "name", "somerandom"]
        let normalizedComplexURLIgnoringParameters = "example.com:8042/over/there/index.html?type#red"
        XCTAssertTrue(complexURL.normalizedString == normalizedComplexURLIgnoringParameters, "Normalized version must match & must ignore specified params")
    }

    func testCapitalURLNormalization() {
        Spoofer.normalizeQueryValues = true
        let normalizedAllCapsURL = "jsonplaceholder.typicode.com/users"
        XCTAssertTrue(allCapsURL.normalizedString == normalizedAllCapsURL, "After normalization, all URL's should be lower case")
    }

    func testPathIgnoreRules() {
        Spoofer.normalizeQueryValues = true
        Spoofer.pathComponentsToNormalize = ["over", "there"]
        let normalizedPathIgnoredURL = "example.com:8042/index.html?class&type&name#red"
        XCTAssertTrue(complexURL.normalizedString == normalizedPathIgnoredURL, "After normalization, path componets should be ignored if specified")
    }
}
