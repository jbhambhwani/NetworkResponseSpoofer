//
//  SpooferState.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/8/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

enum NetworkAction {
    case record(scenarioName: String, suiteName: String)
    case replay(scenarioName: String, suiteName: String)
    case stopIntercept
}

struct SpooferState: Equatable {

    var isRecording = false
    var isReplaying = false
    var scenarioName = ""
    var suiteName = ""

    @discardableResult func transformedState(networkAction: NetworkAction) -> SpooferState {

        switch networkAction {

        case let .record(scenarioName, suiteName):
            return SpooferState(isRecording: true, isReplaying: false, scenarioName: scenarioName, suiteName: suiteName)

        case let .replay(scenarioName, suiteName):
            return SpooferState(isRecording: false, isReplaying: true, scenarioName: scenarioName, suiteName: suiteName)

        case .stopIntercept:
            return SpooferState(isRecording: false, isReplaying: false, scenarioName: "", suiteName: "")
        }
    }
}

func == (lhs: SpooferState, rhs: SpooferState) -> Bool {
    return lhs.isRecording == rhs.isRecording
        && lhs.isReplaying == rhs.isReplaying
        && lhs.scenarioName == rhs.scenarioName
}
