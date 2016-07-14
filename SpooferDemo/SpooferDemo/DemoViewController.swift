//
//  DemoViewController.swift
//  SpooferDemo
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit
import WebKit
import APIResponseSpoofer

class DemoViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var replayButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var consoleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var consolePanGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listen for Spoofer log messages and print on console
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(spooferLogReceived(_:)),
                                                         name: Spoofer.spooferLogNotification,
                                                         object: nil)
        Spoofer.delegate = self
        
        // Sample configurations
        Spoofer.queryParametersToIgnore = ["authtoken", "swarm", "cluster", "node"]
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)        
    }
    
    // MARK: - User Actions
    
    @IBAction func buttonPressed(sender: UIBarButtonItem) {
        
        if sender == clearButton {
            consoleTextView.text = ""
            return
        }
        
        // Reset the alternate button to default state
        switch sender {
        case recordButton:
            replayButton.title = ButtonTitle.StartReplaying.rawValue
            replayButton.tintColor = view.tintColor
            if Spoofer.isReplaying {
                Spoofer.stopReplaying()
            }
            
        case replayButton:
            recordButton.title = ButtonTitle.StartRecording.rawValue
            recordButton.tintColor = view.tintColor
            if Spoofer.isRecording {
                Spoofer.stopRecording()
            }
            
        default:
            print("Invalid button")
        }
        
        // Decide on action and set state for current button press
        switch (sender, sender.title!) {
        case (recordButton, ButtonTitle.StartRecording.rawValue):
            // Start recording
            Spoofer.startRecording(inViewController: self)
            
        case (recordButton, ButtonTitle.StopRecording.rawValue):
            // Stop Recording
            Spoofer.stopRecording()
            
        case (replayButton, ButtonTitle.StartReplaying.rawValue):
            // Start Replay
            Spoofer.showRecordedScenarios(inViewController: self)
            
        case (replayButton, ButtonTitle.StopReplaying.rawValue):
            // Stop Replay
            Spoofer.stopReplaying()
            
        default:
            print("Invalid button state")
        }
    }
    
    // MARK: - Helper methods
    
    @IBAction func handlePan(sender: UIPanGestureRecognizer) {
        let point = sender.translationInView(view)
        consoleHeightConstraint.constant = -point.y
    }
    
    func spooferLogReceived(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: String], message = userInfo["message"] else { return }
        // Marshall the UI updates to main thread
        dispatch_async(dispatch_get_main_queue(), { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.consoleTextView.text.characters.count > 0 {
                strongSelf.consoleTextView.text = strongSelf.consoleTextView.text + "\n" + message
                // Scroll to bottom of log
                strongSelf.consoleTextView.scrollRangeToVisible(NSRange(location: strongSelf.consoleTextView.text.characters.count - 1, length: 1))
            } else {
                strongSelf.consoleTextView.text = message
            }
        })
    }
    
    func executeActionsForRecording(recordingState state: Bool) {
        if state {
            webview.loadHTMLString("<html></html>", baseURL: nil) // Hacky clear screen of the webview
            recordButton.title = ButtonTitle.StopRecording.rawValue
            recordButton.tintColor = UIColor.redColor()
            performSampleNetworkRequests()
        } else {
            recordButton.title = ButtonTitle.StartRecording.rawValue
            recordButton.tintColor = view.tintColor
        }
    }
    
    func executeActionsForReplaying(replayingState state: Bool) {
        if state {
            webview.loadHTMLString("<html></html>", baseURL: nil) // Hacky clear screen of the webview
            replayButton.title = ButtonTitle.StopReplaying.rawValue
            replayButton.tintColor = UIColor.redColor()
        } else {
            replayButton.title = ButtonTitle.StartReplaying.rawValue
            replayButton.tintColor = view.tintColor
        }
    }
    
}


// MARK: - Spoofer Delegate

extension DemoViewController: SpooferDelegate {
    func spooferDidStartRecording(scenarioName: String) {
        executeActionsForRecording(recordingState: true)
    }
    
    func spooferDidStopRecording(scenarioName: String, success: Bool) {
        executeActionsForRecording(recordingState: false)
    }
    
    func spooferDidStartReplaying(scenarioName: String, success: Bool) {
        executeActionsForReplaying(replayingState: true)
    }
    
    func spooferDidStopReplaying(scenarioName: String) {
        executeActionsForReplaying(replayingState: false)
    }
}
