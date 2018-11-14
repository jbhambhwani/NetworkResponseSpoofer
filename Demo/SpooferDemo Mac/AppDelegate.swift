//
//  AppDelegate.swift
//  SpooferDemo Mac
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Cocoa
import NetworkResponseSpoofer

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        // Insert code here to initialize your application
        Spoofer.runMigrations()
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
}
