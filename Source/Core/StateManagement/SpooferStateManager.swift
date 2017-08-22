//
//  SpooferStateManager.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/8/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

final class SpooferStateManager {

    private(set) var state = SpooferState()

    @discardableResult func transformState(networkAction: NetworkAction) -> SpooferState {
        let oldState = state
        let newState = state.transformedState(networkAction: networkAction)
        // Update to the new state
        state = newState
        // Broadcast state change to all listeners
        broadcastStateChange(oldState: oldState, newState: newState)
        return newState
    }
}

extension SpooferStateManager {

    /// Broadcast spoofer activation and deactivation through all mediums

    func broadcastStateChange(oldState: SpooferState, newState: SpooferState) {

        switch (newState.isRecording, newState.isReplaying) {

        case (true, _):
            logFormattedSeperator("Spoofer Recording Started")
            Spoofer.delegate?.spooferDidStartRecording(newState.scenarioName)
            NotificationCenter.default.post(name: Notification.Name(rawValue: Spoofer.spooferStartedRecordingNotification), object: Spoofer.sharedInstance, userInfo: ["scenario": newState.scenarioName])

        case (_, true):
            logFormattedSeperator("Spoofer Replay Started")
            Spoofer.delegate?.spooferDidStartReplaying(newState.scenarioName)
            NotificationCenter.default.post(name: Notification.Name(rawValue: Spoofer.spooferStartedReplayingNotification), object: Spoofer.sharedInstance, userInfo: ["scenario": newState.scenarioName])
            break

        case (false, false):

            switch (oldState.isRecording, oldState.isReplaying) {

            case (true, _):
                logFormattedSeperator("Spoofer Recording Stopped")
                Spoofer.delegate?.spooferDidStopRecording(oldState.scenarioName)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Spoofer.spooferStoppedRecordingNotification), object: Spoofer.sharedInstance, userInfo: ["scenario": oldState.scenarioName])

            case (_, true):
                logFormattedSeperator("Spoofer Replay Stopped")
                Spoofer.delegate?.spooferDidStopReplaying(oldState.scenarioName)
                NotificationCenter.default.post(name: Notification.Name(rawValue: Spoofer.spooferStoppedReplayingNotification), object: Spoofer.sharedInstance, userInfo: ["scenario": oldState.scenarioName])

            default:
                break
            }

        default:
            break
        }
    }
}
