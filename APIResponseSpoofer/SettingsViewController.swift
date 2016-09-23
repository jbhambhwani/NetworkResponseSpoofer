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
    var allSettings = [[SpooferConfigurationType: Any]]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readSpooferConfiguration()
        tableView.reloadData()
    }
    
    private func readSpooferConfiguration() {
        allSettings.removeAll(keepingCapacity: true)
        guard let config = Spoofer.configurations else { return }
        for (k, v) in Array(config).sorted(by: { $0.0.rawValue < $1.0.rawValue })  {
            allSettings.append([k:v])
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? SwitchWithTextTableViewCell, let editVC = segue.destination as? EditSettingsViewController else { return }
        editVC.title = cell.presenter?.title
        editVC.presenter = cell.presenter
    }
    
}


extension SettingsViewController {
    
    // MARK: - Tableview datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSettings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SwitchWithTextTableViewCell.defaultReuseIdentifier, for: indexPath) as! SwitchWithTextTableViewCell
        let viewModel = SwitchWithTextViewModel(model: allSettings[(indexPath as NSIndexPath).row])
        cell.configure(withPresenter: viewModel)
        return cell
    }
    
    // MARK: - Tableview delegate
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let cell = tableView.cellForRow(at: indexPath) as? SwitchWithTextTableViewCell,
        let allowSelect = cell.presenter?.allowCellSelection else { return nil }
        return allowSelect ? indexPath : nil
    }
}
