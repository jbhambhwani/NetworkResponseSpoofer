//
//  SuiteListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/25/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import UIKit

class SuiteListController: UITableViewController {

    var suiteName = defaultSuiteName
}

extension SuiteListController {

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return FileManager.allSuiteNames().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SuiteCell", for: indexPath)
        cell.textLabel?.text = FileManager.allSuiteNames()[indexPath.row]
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        suiteName = FileManager.allSuiteNames()[indexPath.row]
        performSegue(withIdentifier: "unwindToRecordViewController", sender: self)
    }
}

extension SuiteListController {

    @IBAction func addSuitePressed(_: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Create Suite", message: "Enter a suite name to save the scenarios", preferredStyle: .alert)

        let createAction = UIAlertAction(title: "Create", style: .default) { [unowned alertController, weak self] _ in
            if let textField = alertController.textFields?.first, let suiteName = textField.text {
                // Easy hack to create a suite file by fetching its scenarios
                DataStore.allScenarioNames(suite: suiteName)
                self?.tableView.reloadData()
            }
        }
        createAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Dismiss
        }

        alertController.addTextField { textField in
            textField.placeholder = "Enter suite name"
            textField.autocapitalizationType = .sentences
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { _ in
                createAction.isEnabled = textField.text != ""
            }
        }

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
