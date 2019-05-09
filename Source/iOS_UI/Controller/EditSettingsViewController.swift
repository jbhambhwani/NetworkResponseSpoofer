//
//  EditSettingsViewController.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import NetworkResponseSpoofer
import UIKit

final class EditSettingsViewController: UITableViewController {
    var presenter: SwitchWithTextViewPresentable?
    private var validatorToken1: NotificationToken?
    private var validatorToken2: NotificationToken?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - User Actions

    @IBAction func addAction(_: UIBarButtonItem) {
        let alertController = UIAlertController(title: title,
                                                message: "Add an entry to the list",
                                                preferredStyle: .alert)

        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned alertController, unowned self] _ in
            if let textFields = alertController.textFields {
                if textFields.count > 1,
                    let start = textFields[0].text,
                    let end = textFields[1].text,
                    let replacement = textFields[2].text {
                    let prReplacement = URLPathRangeReplacement(start: start, end: end, replacement: replacement)
                    self.presenter?.configurations.append(prReplacement)
                } else if let entry = textFields[0].text {
                    self.presenter?.configurations.append(entry)
                }

                self.tableView?.reloadData()
            }
        }
        addAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }

        if title == "Replace Path Range" {
            alertController.addTextField { [weak self] textField in
                textField.placeholder = "From"
                textField.autocapitalizationType = .none
                self?.validatorToken1 = NotificationCenter.default.observe(name: UITextField.textDidChangeNotification,
                                                                           object: textField,
                                                                           queue: OperationQueue.main) { _ in
                    addAction.isEnabled = textField.text != ""
                }
            }

            alertController.addTextField { textField in
                textField.placeholder = "To"
                textField.autocapitalizationType = .none
            }

            alertController.addTextField { textField in
                textField.placeholder = "Replacement"
                textField.autocapitalizationType = .none
            }
        } else {
            alertController.addTextField { [weak self] textField in
                textField.placeholder = "Enter here!"
                textField.autocapitalizationType = .none
                self?.validatorToken2 = NotificationCenter.default.observe(name: UITextField.textDidChangeNotification,
                                                                           object: textField,
                                                                           queue: OperationQueue.main) { _ in
                    addAction.isEnabled = textField.text != ""
                }
            }
        }

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @IBAction func editAction(_: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
}

// MARK: - Tableview datasource

extension EditSettingsViewController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let configurations = presenter?.configurations else { return 0 }
        return configurations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let configurations = presenter?.configurations else { return UITableViewCell() }

        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier, for: indexPath)
        let object = configurations[indexPath.row]
        if let text = object as? String {
            cell.textLabel?.text = text
            cell.detailTextLabel?.text = nil
        } else if let prr = object as? URLPathRangeReplacement {
            cell.textLabel?.text = "FROM: " + prr.start + "     TO: " + (prr.end ?? "End")
            cell.detailTextLabel?.text = "Replace with: " + prr.replacement
        }
        return cell
    }
}

// MARK: - Tableview delegate

extension EditSettingsViewController {
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            presenter?.configurations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case .insert: break
        case .none: break
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return tableView.deselectRow(at: indexPath, animated: true)
    }
}
