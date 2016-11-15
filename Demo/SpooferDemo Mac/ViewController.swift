//
//  ViewController.swift
//  SpooferDemo Mac
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var textField: NSTextField!
    
    @IBAction func goPressed(_ sender: NSButton) {
        print(textField.stringValue)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}


