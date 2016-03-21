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
    
    var presenter: SwitchWithTextViewPresentable?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - User Actions
    
    @IBAction func addAction(sender: UIBarButtonItem) {
        // TODO: Add this functionality
    }
    
    @IBAction func editAction(sender: UIBarButtonItem) {
        tableView.editing = !tableView.editing
    }
    
}

// MARK: - Tableview datasource

extension EditSettingsViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let configurations = presenter?.configurations else { return 0 }
        return configurations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let configurations = presenter?.configurations else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(UITableViewCell.defaultReuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = configurations[indexPath.row]
        return cell
    }
    
}

// MARK: - Tableview delegate

extension EditSettingsViewController {
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
            case .Delete:
                presenter?.configurations.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case .Insert: break
            case .None: break
        }
    }
    
}