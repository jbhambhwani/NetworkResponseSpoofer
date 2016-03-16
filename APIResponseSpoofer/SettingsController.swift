//
//  SettingsController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/15/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import UIKit

class SettingsController: UITableViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        readSpooferConfiguration()
    }
    
    func readSpooferConfiguration() {
        
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath)
        //TODO: Configure cell
        return cell
    }
    
    // Tableview Delegate
    
}
