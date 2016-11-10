//
//  SpooferState.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/8/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

enum NetworkAction {
    case record(scenarioName: String)
    case replay(scenarioName: String)
    case stopIntercept
}

struct SpooferState: Equatable {
    
    var isRecording = false
    var isReplaying = false
    var scenarioName = ""
    
    @discardableResult func transformedState(networkAction: NetworkAction) -> SpooferState {
        
        switch networkAction {
        
        case .record(let scenarioName):
            return SpooferState(isRecording: true, isReplaying: false, scenarioName: scenarioName)
        
        case .replay(let scenarioName):
            return SpooferState(isRecording: false, isReplaying: true, scenarioName: scenarioName)
        
        case .stopIntercept:
            return SpooferState(isRecording: false, isReplaying: false, scenarioName: "")
        }
    }
}

func ==(lhs: SpooferState, rhs: SpooferState) -> Bool {
    return lhs.isRecording == rhs.isRecording
        && lhs.isReplaying == rhs.isReplaying
        && lhs.scenarioName == rhs.scenarioName
}
