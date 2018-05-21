//
//  ViewController.swift
//  SpooferDemo Mac
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import APIResponseSpoofer
import Cocoa
import WebKit

final class ViewController: NSViewController {
    @IBOutlet var webView: WebView!
    @IBOutlet var textField: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frameLoadDelegate = self
    }

    @IBAction func goPressed(_: NSButton) {
        loadWebPage()
    }

    @IBAction func enterPressed(_: NSTextField) {
        loadWebPage()
    }

    func loadWebPage() {
        let url = textField.stringValue
        guard url.count > 0 else { return }
        Spoofer.startRecording(scenarioName: "MacApp")
        webView.mainFrameURL = url.hasPrefix("http") ? url : "https://\(url)"
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
