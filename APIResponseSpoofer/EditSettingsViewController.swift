//
//  EditSettingsViewController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import UIKit

class EditSettingsViewController: UITableViewController {
    
    var configurations: [String]?
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let configurations = configurations else { return 0 }
        return configurations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let configurations = configurations else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(UITableViewCell.defaultReuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = configurations[indexPath.row]
        return cell
    }
}