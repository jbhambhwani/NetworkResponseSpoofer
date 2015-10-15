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
    
    @IBAction func buttonPressed(sender: UIBarButtonItem) {
        
        // Reset the alternate button to default state
        switch sender {
        case recordButton:
            replayButton.title = ButtonTitle.StartReplaying.rawValue
            replayButton.tintColor = UIColor.blueColor()
            Spoofer.stopReplaying()
            
        case replayButton:
            recordButton.title = ButtonTitle.StartRecording.rawValue
            recordButton.tintColor = UIColor.blueColor()
            Spoofer.stopRecording()
            
        default:
            print("Invalid button")
        }
        
        // Decide on action and set state for current button press
        switch (sender, sender.title!) {
        case (recordButton, ButtonTitle.StartRecording.rawValue):
            // Start Recording some network requests
            sender.title = ButtonTitle.StopRecording.rawValue
            sender.tintColor = UIColor.redColor()
            Spoofer.startRecording(scenarioName: newScenarioName)
            performSampleNetworkRequests()
            
        case (recordButton, ButtonTitle.StopRecording.rawValue):
            // Stop Recording
            sender.title = ButtonTitle.StartRecording.rawValue
            sender.tintColor = UIColor.blueColor()
            Spoofer.stopRecording()
            
        case (replayButton, ButtonTitle.StartReplaying.rawValue):
            // Start Replay
            sender.title = ButtonTitle.StopReplaying.rawValue
            sender.tintColor = UIColor.redColor()
            Spoofer.showRecordedScenarios(inViewController: self)
            
        case (replayButton, ButtonTitle.StopReplaying.rawValue):
            // Stop Replay
            sender.title = ButtonTitle.StartReplaying.rawValue
            sender.tintColor = UIColor.blueColor()
            Spoofer.stopReplaying()
            
        default:
            print("Invalid button state")
        }
    }
    
    // MARK: - Helper methods
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



