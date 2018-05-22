//
//  ResponseListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/13/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit

final class ResponseListController: UITableViewController {
    var suiteName = ""
    var scenarioName = ""
    var cellHeight: CGFloat = 60.0
    let expandText = "Expand"
    let collapseText = "Collapse"

    private var allResponses = [APIResponse]()
    private var filteredResponses = [APIResponse]()

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
        // tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: expandText, style: .plain, target: self, action: #selector(ResponseListController.toggleRowHeight(_:)))
        // Load the responses for the passed in scenario
        if scenarioName.count > 0 {
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
            allResponses = Array(scenario.apiResponses)
            tableView.reloadData()
        case .failure:
            break
        }
    }

    @objc func toggleRowHeight(_ sender: UIBarButtonItem) {
        if sender.title == expandText {
            sender.title = collapseText
            cellHeight = UITableViewAutomaticDimension
        } else {
            sender.title = expandText
            cellHeight = 60.0
        }
        searchController.isActive = false
        tableView.reloadData()
    }
}

// MARK: - Tableview datasource

extension ResponseListController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchController.isActive ? filteredResponses.count : allResponses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResponseCell.defaultReuseIdentifier, for: indexPath) as! ResponseCell

        let response = searchController.isActive ? filteredResponses[indexPath.row] : allResponses[indexPath.row]

        cell.urlLabel.text = response.requestURL

        if [".png", ".jpg", ".jpeg", ".tiff", ".tif", ".gif", ".bmp", ".ico"]
            .filter({ response.requestURL.hasSuffix($0) }).count == 1 {
            cell.reponseImageView.image = UIImage(data: response.data)
        }

        return cell
    }
}

// MARK: - Tableview delegate

extension ResponseListController {
    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return cellHeight
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
            return $0.requestURL.contains(searchText.lowercased())
        }
    }
}
