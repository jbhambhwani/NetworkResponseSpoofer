//
//  SettingsViewController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/15/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    // Array of dictionaries of Spoofer Configuration Type: AnyObject
    var allSettings = [[SpooferConfigurationType : AnyObject]]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        readSpooferConfiguration()
        tableView.tableFooterView = UIView()
    }
    
    private func readSpooferConfiguration() {
        guard let config = Spoofer.configurations else { return }
        for (k,v) in Array(config).sort({ $0.0.rawValue < $1.0.rawValue })  {
            allSettings.append([k:v])
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let cell = sender as? SwitchWithTextTableViewCell, editVC = segue.destinationViewController as? EditSettingsViewController else { return }
        editVC.title = cell.presenter?.text
        editVC.configurations = cell.presenter?.configurations
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSettings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SwitchWithTextTableViewCell.defaultReuseIdentifier, forIndexPath: indexPath) as! SwitchWithTextTableViewCell
        let viewModel = SwitchWithTextViewModel(model: allSettings[indexPath.row])
        cell.configure(withPresenter: viewModel)
        return cell
    }
    
}
