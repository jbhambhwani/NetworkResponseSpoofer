//
//  ViewController.swift
//  SpooferDemo
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit
import WebKit
import APIResponseSpoofer

class ViewController: UIViewController, UISearchBarDelegate, UIWebViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var recordButton: UIBarButtonItem!
    @IBOutlet weak var replayButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private enum ButtonTitle: String {
        case StartRecording = "Start Recording"
        case StopRecording = "Stop Recording"
        case StartReplaying = "Start Replaying"
        case StopReplaying = "Stop Replaying"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("spooferLogReceived:"), name: SpooferLogNotification, object: nil)
        Spoofer.delegate = self
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
    func spooferLogReceived(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: String], message = userInfo["message"] else { return }
        // Marshall the UI updates to main thread
        dispatch_async(dispatch_get_main_queue(), {
            if self.consoleTextView.text.characters.count > 0 {
                self.consoleTextView.text = self.consoleTextView.text + "\n" + message
                // Scroll to bottom of log
                self.consoleTextView.scrollRangeToVisible(NSRange(location: self.consoleTextView.text.characters.count - 1, length: 1))
            } else {
                self.consoleTextView.text = message
            }
        })
    }
    
    func performSampleNetworkRequests() {
        // Get data from a few sample end points
        sendRequest("http://jsonplaceholder.typicode.com/users")
        sendRequest("http://jsonplaceholder.typicode.com/posts")
    }
    
    func sendRequest(resource: String) {
        guard let url = NSURL(string: resource) else { return }
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { data, response, error in
            // Spoofer has already intercepted the response if error was non nil. Nothing to do here.
        }).resume()
    }
    
    func executeActionsForRecording(recordingState state: Bool) {
        if state {
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
            replayButton.title = ButtonTitle.StopReplaying.rawValue
            replayButton.tintColor = UIColor.redColor()
        } else {
            replayButton.title = ButtonTitle.StartReplaying.rawValue
            replayButton.tintColor = view.tintColor
        }
    }
    
    // MARK: - SearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard var searchText = searchBar.text where searchText.characters.count > 0 else { return }
        if !searchText.hasPrefix("http") {
            searchText = "http://" + searchText
        }
        guard let url = NSURL(string: searchText) else { return }
        
        let urlRequest = NSURLRequest(URL: url)
        webView.loadRequest(urlRequest)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Webview Delegate
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        activityIndicator.stopAnimating()
    }
    
}

// MARK: - Spoofer Delegate
extension ViewController: SpooferDelegate {
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


