//
//  SuiteListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/25/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import UIKit

class SuiteListController: UITableViewController {

    static let identifier = "SuiteListController"

    var suiteName = defaultSuiteName

    @IBOutlet var addSuiteButton: UIBarButtonItem!
}

extension SuiteListController {

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return FileManager.allSuiteNames().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier, for: indexPath)
        cell.textLabel?.text = FileManager.allSuiteNames()[indexPath.row]
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Save the suite name for other controllers
        suiteName = FileManager.allSuiteNames()[indexPath.row]

        switch navigationController?.viewControllers.first {
        case is RecordTableViewController:
            print("Record")
            performSegue(withIdentifier: SegueIdentifier.unwindToRecordViewController.rawValue, sender: self)
        case is SuiteListController:
            print("Replay")
            performSegue(withIdentifier: SegueIdentifier.showScenarios.rawValue, sender: self)
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        switch segue.destination {
        case let controller as ScenarioListController:
            controller.suiteName = suiteName
        default:
            break
        }
    }
}

extension SuiteListController {

    @IBAction func cancel() {
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func addSuitePressed(_: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Create Suite", message: "Enter a suite name to save the scenarios", preferredStyle: .alert)

        let createAction = UIAlertAction(title: "Create", style: .default) { [unowned alertController, weak self] _ in
            if let textField = alertController.textFields?.first, let suiteName = textField.text {
                // Easy hack to create a suite file by fetching its scenarios
                _ = DataStore.allScenarioNames(suite: suiteName)
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
