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
    
    // Array of dictionaries of Spoofer Configuration Type: AnyObject
    var allSettings = [[SpooferConfigurationType : AnyObject]]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        readSpooferConfiguration()
    }
    
    func readSpooferConfiguration() {
        guard let config = Spoofer.configurations else { return }
        for (k,v) in Array(config).sort({ $0.0.rawValue < $1.0.rawValue })  {
            allSettings.append([k:v])
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSettings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsCell", forIndexPath: indexPath)
        cell.textLabel?.text = allSettings[indexPath.row].keys.first?.rawValue
        return cell
    }

}
