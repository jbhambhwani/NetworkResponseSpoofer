//
//  ResponseListController.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 11/13/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
#if !COCOAPODS
import NetworkResponseSpoofer
#endif
import UIKit

final class ResponseListController: UITableViewController {
    var suiteName = ""
    var scenarioName = ""

    private var allResponses = [NetworkResponse]()
    private var filteredResponses = [NetworkResponse]()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.searchBar.backgroundColor = .darkGray
        controller.hidesNavigationBarDuringPresentation = false
        controller.obscuresBackgroundDuringPresentation = false
        controller.definesPresentationContext = true
        return controller
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true

        tableView.tableHeaderView = searchController.searchBar
        // Load the responses for the passed in scenario
        if !scenarioName.isEmpty {
            loadResponses()
        }
    }

    deinit {
        searchController.loadViewIfNeeded()
    }

    // MARK: Utility methods

    func loadResponses() {
        allResponses = []
        filteredResponses = []
        searchController.isActive = false
        let loadResult = DataStore.load(scenarioName: scenarioName, suite: suiteName)
        switch loadResult {
        case let .success(scenario):
            allResponses = Array(scenario.networkResponses)
            tableView.reloadData()
        case .failure:
            break
        }
    }
}

// MARK: - Tableview datasource

extension ResponseListController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchController.isActive ? filteredResponses.count : allResponses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ResponseCell.defaultReuseIdentifier,
                                                       for: indexPath) as? ResponseCell else { return UITableViewCell() }

        let response = searchController.isActive ? filteredResponses[indexPath.row] : allResponses[indexPath.row]
        cell.configure(with: response)

        return cell
    }
}

// MARK: - Tableview delegate

extension ResponseListController {
    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let responseToDelete = searchController.isActive ? filteredResponses[indexPath.row] : allResponses[indexPath.row]
            _ = DataStore.delete(response: responseToDelete, scenarioName: scenarioName, suite: suiteName)
            loadResponses()

        default: break
        }
    }
}

// MARK: - Search controller delegate

extension ResponseListController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        defer {
            tableView.reloadData()
        }

        guard let searchText = searchController.searchBar.text else {
            filteredResponses = allResponses
            return
        }

        filteredResponses = allResponses.filter {
            let url = $0.requestURL
            return url.contains(searchText.lowercased())
        }
    }
}
