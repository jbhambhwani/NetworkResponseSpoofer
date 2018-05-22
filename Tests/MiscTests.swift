//
//  MiscTests.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/11/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import XCTest
@testable import APIResponseSpoofer

final class MiscTests: XCTestCase {

    func testFormattedSeperator() {
        logFormattedSeperator("Scenario Loaded Succesfully 👍")
        logFormattedSeperator("")
        logFormattedSeperator("-")
        logFormattedSeperator("+")
        logFormattedSeperator("@")
        logFormattedSeperator("This string is 100 characters plus to that it breaks the formated seperator logic. Yes. Break the logic. That's the test. The method should just print this string as it is.")
    }
}
