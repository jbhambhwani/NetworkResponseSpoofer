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
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()
    
    private var newScenarioName: String {
        // Generate a scenario name from current timestamp
        return "Scenario-\(dateFormatter.stringFromDate(NSDate()))"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("spooferLogReceived:"), name: SpooferLogNotification, object: nil)
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
            // Start Recording some network requests
            sender.title = ButtonTitle.StopRecording.rawValue
            sender.tintColor = UIColor.redColor()
            Spoofer.startRecording(scenarioName: newScenarioName, inViewController: self)
            performSampleNetworkRequests()
            
        case (recordButton, ButtonTitle.StopRecording.rawValue):
            // Stop Recording
            sender.title = ButtonTitle.StartRecording.rawValue
            sender.tintColor = view.tintColor
            Spoofer.stopRecording()
            
        case (replayButton, ButtonTitle.StartReplaying.rawValue):
            // Start Replay
            sender.title = ButtonTitle.StopReplaying.rawValue
            sender.tintColor = UIColor.redColor()
            Spoofer.showRecordedScenarios(inViewController: self)
            
        case (replayButton, ButtonTitle.StopReplaying.rawValue):
            // Stop Replay
            sender.title = ButtonTitle.StartReplaying.rawValue
            sender.tintColor = view.tintColor
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



