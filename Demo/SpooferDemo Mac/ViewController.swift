//
//  ViewController.swift
//  SpooferDemo Mac
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Cocoa
import WebKit
import APIResponseSpoofer

class ViewController: NSViewController {

    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frameLoadDelegate = self
    }

    @IBAction func goPressed(_ sender: NSButton) {
        loadWebPage()
    }

    @IBAction func enterPressed(_ sender: NSTextField) {
        loadWebPage()
    }

    func loadWebPage() {
        let url = textField.stringValue
        guard url.characters.count > 0 else { return }
        Spoofer.startRecording(scenarioName: "MacApp")
        webView.mainFrameURL = url.hasPrefix("http") ? url : "http://\(url)"
    }
}

extension ViewController: WebFrameLoadDelegate {

    func webView(_ sender: WebView!, didStartProvisionalLoadFor frame: WebFrame!) {
        progressIndicator.startAnimation(nil)
    }

    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        progressIndicator.stopAnimation(nil)
    }

    func webView(_ sender: WebView!, didFailLoadWithError error: Error!, for frame: WebFrame!) {
        progressIndicator.stopAnimation(nil)
    }
}

