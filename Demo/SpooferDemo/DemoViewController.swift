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

    private var offset: CGFloat = 0

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Listen for Spoofer log messages and print on console
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spooferLogReceived(_:)),
                                               name: NSNotification.Name(rawValue: Spoofer.spooferLogNotification),
                                               object: nil)
        Spoofer.delegate = self
        
        // Sample configurations (not exhaustive)
        Spoofer.hostNamesToIgnore = ["example.com", "somehosttobeignored.com"]
        Spoofer.subDomainsToNormalize = ["qa", "dev", "preprod"]
        Spoofer.queryParametersToNormalize = ["authtoken", "swarm", "cluster", "node"]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)        
    }
    
    // MARK: - User Actions
    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
        
        if sender == clearButton {
            consoleTextView.text = ""
            return
        }
        
        // Reset the alternate button to default state
        switch sender {
        case recordButton:
            replayButton.title = ButtonTitle.startReplaying.rawValue
            replayButton.tintColor = view.tintColor
            if Spoofer.isReplaying {
                Spoofer.stopReplaying()
            }
            
        case replayButton:
            recordButton.title = ButtonTitle.startRecording.rawValue
            recordButton.tintColor = view.tintColor
            if Spoofer.isRecording {
                Spoofer.stopRecording()
            }
            
        default:
            print("Invalid button")
        }
        
        // Decide on action and set state for current button press
        switch (sender, sender.title!) {
        case (recordButton, ButtonTitle.startRecording.rawValue):
            Spoofer.startRecording(inViewController: self)
            
        case (recordButton, ButtonTitle.stopRecording.rawValue):
            Spoofer.stopRecording()
            
        case (replayButton, ButtonTitle.startReplaying.rawValue):
            Spoofer.showRecordedScenarios(inViewController: self)
            
        case (replayButton, ButtonTitle.stopReplaying.rawValue):
            Spoofer.stopReplaying()
            
        default:
            print("Invalid button state")
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let point = sender.translation(in: view)

        switch sender.state {
        case .began:
            offset = consoleHeightConstraint.constant
        case .changed:
            consoleHeightConstraint.constant = -point.y + offset
        default:
            break
        }
    }

    // MARK: - Helper methods

    @objc func spooferLogReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String], let message = userInfo["message"] else { return }
        // Marshall the UI updates to main thread
        DispatchQueue.main.async(execute: { [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.consoleTextView.text.count > 0 {
                strongSelf.consoleTextView.text = strongSelf.consoleTextView.text + "\n" + message
                // Scroll to bottom of log
                strongSelf.consoleTextView.scrollRangeToVisible(NSRange(location: strongSelf.consoleTextView.text.count - 1, length: 1))
            } else {
                strongSelf.consoleTextView.text = message
            }
        })
    }

}

// MARK: - Spoofer Delegate

extension DemoViewController: SpooferDelegate {

    func spooferDidStartRecording(_ scenarioName: String) {
        executeActionsForRecording(recordingState: true)
    }
    
    func spooferDidStopRecording(_ scenarioName: String) {
        executeActionsForRecording(recordingState: false)
    }
    
    func spooferDidStartReplaying(_ scenarioName: String) {
        executeActionsForReplaying(replayingState: true)
    }
    
    func spooferDidStopReplaying(_ scenarioName: String) {
        executeActionsForReplaying(replayingState: false)
    }
}

private extension DemoViewController {

    func executeActionsForRecording(recordingState state: Bool) {
        if state {
            webview.loadHTMLString("<html></html>", baseURL: nil) // Hacky clear screen of the webview
            searchBar.text = ""
            recordButton.title = ButtonTitle.stopRecording.rawValue
            recordButton.tintColor = UIColor.red
            performSampleNetworkRequests()
        } else {
            recordButton.title = ButtonTitle.startRecording.rawValue
            recordButton.tintColor = view.tintColor
        }
    }

    func executeActionsForReplaying(replayingState state: Bool) {
        if state {
            webview.loadHTMLString("<html></html>", baseURL: nil) // Hacky clear screen of the webview
            searchBar.text = ""
            replayButton.title = ButtonTitle.stopReplaying.rawValue
            replayButton.tintColor = UIColor.red
        } else {
            replayButton.title = ButtonTitle.startReplaying.rawValue
            replayButton.tintColor = view.tintColor
        }
    }

}
