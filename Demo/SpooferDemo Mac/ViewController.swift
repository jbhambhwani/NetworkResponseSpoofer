//
//  ViewController.swift
//  SpooferDemo Mac
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Cocoa
import NetworkResponseSpoofer
import WebKit

final class ViewController: NSViewController {
    @IBOutlet var recordReplaySegmentedControl: NSSegmentedControl!
    @IBOutlet var webView: WebView!
    @IBOutlet var textField: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var consoleTextView: NSTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frameLoadDelegate = self
        consoleTextView.textColor = NSColor.green

        // Listen for Spoofer log messages and print on console
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spooferLogReceived(_:)),
                                               name: NSNotification.Name(rawValue: Spoofer.spooferLogNotification),
                                               object: nil)
    }

    @IBAction func goPressed(_: NSButton) {
        loadWebPage()
    }

    @IBAction func enterPressed(_: NSTextField) {
        loadWebPage()
    }

    func loadWebPage() {
        let url = textField.stringValue
        guard !url.isEmpty else { return }

        switch recordReplaySegmentedControl.selectedSegment {
        case 0:
            Spoofer.startRecording(scenarioName: "MacApp")
        case 1:
            Spoofer.startReplaying(scenarioName: "MacApp")
        default:
            break
        }

        webView.mainFrameURL = url.hasPrefix("http") ? url : "https://\(url)"
    }

    // MARK: - Helper methods

    @objc func spooferLogReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: String], let message = userInfo["message"] else { return }
        // Marshall the UI updates to main thread
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.consoleTextView.string.isEmpty {
                strongSelf.consoleTextView.string += "\n" + message
                // Scroll to bottom of log
                let bottomRange = NSRange(location: strongSelf.consoleTextView.string.count - 1, length: 1)
                strongSelf.consoleTextView.scrollRangeToVisible(bottomRange)
            } else {
                strongSelf.consoleTextView.string = message
            }
        }
    }
}

extension ViewController: WebFrameLoadDelegate {
    func webView(_: WebView!, didStartProvisionalLoadFor _: WebFrame!) {
        progressIndicator.startAnimation(nil)
    }

    func webView(_: WebView!, didFinishLoadFor _: WebFrame!) {
        progressIndicator.stopAnimation(nil)
    }

    func webView(_: WebView!, didFailLoadWithError _: Error!, for _: WebFrame!) {
        progressIndicator.stopAnimation(nil)
    }
}
