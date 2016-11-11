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
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: title, message: "Add an entry to the list", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned alertController, unowned self] (_) in
            if let textField = alertController.textFields?.first, let entry = textField.text {
                self.presenter?.configurations.append(entry)
                self.tableView?.reloadData()
            }
        }
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter here!"
            textField.autocapitalizationType = .none
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                addAction.isEnabled = textField.text != ""
            }
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
}

// MARK: - Tableview datasource

extension EditSettingsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let configurations = presenter?.configurations else { return 0 }
        return configurations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configurations = presenter?.configurations else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier, for: indexPath)
        cell.textLabel?.text = configurations[(indexPath as IndexPath).row]
        return cell
    }
    
}

// MARK: - Tableview delegate

extension EditSettingsViewController {
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            case .delete:
                presenter?.configurations.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .insert: break
            case .none: break
        }
    }
    
}
