//
//  Constants.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

// MARK: Public Enums

public enum SpooferError: Int, ErrorType {
    case DiskReadError = 500
    case DiskWriteError = 501
    case EmptyFileError = 502
    case DocumentsAccessError = 503
    case FolderCreationError = 504
    case EmptyScenarioError = 505
    case NoSavedResponseError = 506
}

// MARK: - Notifications
public let SpooferStartedRecordingNotification = "SpooferStartedRecordingNotification"
public let SpooferStoppedRecordingNotification = "SpooferStoppedRecordingNotification"
public let SpooferStartedReplayingNotification = "SpooferStartedReplayingNotification"
public let SpooferStoppedReplayingNotification = "SpooferStoppedReplayingNotification"