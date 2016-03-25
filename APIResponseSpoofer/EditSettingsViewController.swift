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
        let alertController = UIAlertController(title: title, message: "Add an entry to the list", preferredStyle: .Alert)
        
        let addAction = UIAlertAction(title: "Add", style: .Default) { [unowned alertController, unowned self] (_) in
            if let textField = alertController.textFields?.first, entry = textField.text {
                self.presenter?.configurations.append(entry)
                self.tableView?.reloadData()
            }
        }
        addAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Enter here!"
            textField.autocapitalizationType = .None
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                addAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
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