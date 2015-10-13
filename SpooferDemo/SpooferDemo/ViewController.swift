//
//  ViewController.swift
//  SpooferDemo
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit
import APIResponseSpoofer

class ViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var resultsTextView: UITextView!

    enum ButtonTitle: String {
        case StartRecording = "Start Recording"
        case StopRecording = "Stop Recording"
        case StartReplaying = "Start Replaying"
        case StopReplaying = "Stop Replaying"
    }
    
    lazy var dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }()
    
    var newScenarioName: String {
        // Generate a scenario name from current timestamp
        return "Scenario-\(dateFormatter.stringFromDate(NSDate()))"
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        
        // Reset the alternate button to default state
        switch sender {
        case recordButton:
            replayButton.setTitle(ButtonTitle.StartReplaying.rawValue, forState: .Normal)
            replayButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            
        case replayButton:
            recordButton.setTitle(ButtonTitle.StartRecording.rawValue, forState: .Normal)
            recordButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
            
        default:
            print("Invalid button")
        }
        
        // Decide on action and set state for current button press
        switch (sender, sender.currentTitle!) {
        case (recordButton, ButtonTitle.StartRecording.rawValue):
            // Start Recording some network requests
            sender.setTitle(ButtonTitle.StopRecording.rawValue, forState: .Normal)
            sender.setTitleColor(UIColor.redColor(), forState: .Normal)
            Spoofer.startRecording(scenarioName: newScenarioName)
            performSampleNetworkRequests()
            
        case (recordButton, ButtonTitle.StopRecording.rawValue):
            // Stop Recording
            sender.setTitle(ButtonTitle.StartRecording.rawValue, forState: .Normal)
            sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
            Spoofer.stopRecording()
            
        case (replayButton, ButtonTitle.StartReplaying.rawValue):
            // Start Replay
            sender.setTitle(ButtonTitle.StopReplaying.rawValue, forState: .Normal)
            sender.setTitleColor(UIColor.redColor(), forState: .Normal)
            Spoofer.showRecordedScenarios(inViewController: self)
            
        case (replayButton, ButtonTitle.StopReplaying.rawValue):
            // Stop Replay
            sender.setTitle(ButtonTitle.StartReplaying.rawValue, forState: .Normal)
            sender.setTitleColor(UIColor.blueColor(), forState: .Normal)
            Spoofer.stopReplaying()
            
        default:
            print("Invalid button state")
        }
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
}



