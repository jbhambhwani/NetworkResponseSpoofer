//
//  SettingsViewController.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 3/15/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
#if !COCOAPODS
    import NetworkResponseSpoofer
#endif
import UIKit

final class SettingsViewController: UITableViewController {
    // Array of dictionaries of Spoofer Configuration Type: Any
    var allSettings = [[SpooferConfigurationType: Any]]()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_: Bool) {
        readSpooferConfiguration()
        tableView.reloadData()
    }

    private func readSpooferConfiguration() {
        allSettings.removeAll(keepingCapacity: true)
        guard let config = Spoofer.configurations else { return }
        for (key, value) in Array(config).sorted(by: { $0.0.rawValue < $1.0.rawValue }) {
            allSettings.append([key: value])
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? SwitchWithTextTableViewCell,
            let editVC = segue.destination as? EditSettingsViewController else { return }
        editVC.title = cell.presenter?.title
        editVC.presenter = cell.presenter
    }
}

extension SettingsViewController {
    // MARK: - Tableview datasource

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return allSettings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchWithTextTableViewCell.defaultReuseIdentifier,
                                                       for: indexPath) as? SwitchWithTextTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = SwitchWithTextViewModel(model: allSettings[indexPath.row])
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
