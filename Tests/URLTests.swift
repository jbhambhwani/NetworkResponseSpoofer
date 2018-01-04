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
        Spoofer.normalizeQueryValues = true
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleURLNormalization() {
        let normalizedSmokeURL = "echo.jsontest.com/key/value/one/two"
        XCTAssertTrue(sampleURL1.normalizedString == normalizedSmokeURL, "Normalized version has to have the host and query parameters values stipped away")
    }

    func testComplexURLNormalization() {
        let normalizedComplexURL = "example.com:8042/over/there/index.html?class&type&name#red"
        XCTAssertTrue(complexURL.normalizedString == normalizedComplexURL, "Normalized version must match")
    }

    func testParameterIgnoreURLNormalization() {
        Spoofer.queryParametersToNormalize = ["class", "name", "somerandom"]
        let normalizedComplexURLIgnoringParameters = "example.com:8042/over/there/index.html?type#red"
        XCTAssertTrue(complexURL.normalizedString == normalizedComplexURLIgnoringParameters, "Normalized version must match & must ignore specified params")
    }

    func testCapitalURLNormalization() {
        let normalizedAllCapsURL = "jsonplaceholder.typicode.com/users"
        XCTAssertTrue(allCapsURL.normalizedString == normalizedAllCapsURL, "After normalization, all URL's should be lower case")
    }

    func testPathIgnoreRules() {
        Spoofer.pathComponentsToNormalize = ["over", "there"]
        let normalizedPathIgnoredURL = "example.com:8042/index.html?class&type&name#red"
        XCTAssertTrue(complexURL.normalizedString == normalizedPathIgnoredURL, "After normalization, path componets should be ignored if specified")
    }

    func testPathReplaceRules01() {
        Spoofer.pathRangesToReplace = [URLPathRangeReplacement(start: "value", end: "two")]
        let normalizedRangeReplacedURL = "echo.jsontest.com/key/value/two"
        XCTAssertTrue(sampleURL1.normalizedString == normalizedRangeReplacedURL, "After normalization, ranges should be replaced if specified")
    }

    func testPathReplaceRules02() {
        Spoofer.pathRangesToReplace = [URLPathRangeReplacement(start: "value", end: nil)]
        let normalizedRangeReplacedURL = "echo.jsontest.com/key/value"
        XCTAssertTrue(sampleURL1.normalizedString == normalizedRangeReplacedURL, "After normalization, ranges should be replaced if specified")
    }

    func testPathReplaceRules03() {
        Spoofer.pathRangesToReplace = [URLPathRangeReplacement(start: "value", end: "two", replacement: "three")]
        let normalizedRangeReplacedURL = "echo.jsontest.com/key/value/three/two"
        XCTAssertTrue(sampleURL1.normalizedString == normalizedRangeReplacedURL, "After normalization, ranges should be replaced if specified")
    }
}
