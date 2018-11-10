//
//  ScenarioListController.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import Foundation
import UIKit
import NetworkResponseSpoofer

final class ScenarioListController: UITableViewController {

    // MARK: - Lifecycle

    var suiteName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedScenarioName = ""
        loadScenarios()
    }

    deinit {
        searchController.loadViewIfNeeded()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let responseListController = segue.destination as? ResponseListController, let indexPath = sender as? IndexPath else { return }
        selectedScenarioName = searchController.isActive ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row]
        responseListController.suiteName = suiteName
        responseListController.scenarioName = selectedScenarioName
    }

    // MARK: - Private properties

    private func loadScenarios() {
        searchController.isActive = false
        scenarioNames = DataStore.allScenarioNames(suite: suiteName)
        tableView.reloadData()
    }

    private var scenarioNames = [String]()
    private var filteredScenarios = [String]()
    private var selectedScenarioName = ""

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
}

// MARK: - Tableview datasource

extension ScenarioListController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchController.isActive ? filteredScenarios.count : scenarioNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.defaultReuseIdentifier, for: indexPath)
        let scenario: String = searchController.isActive ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row]
        cell.textLabel?.text = scenario
        cell.accessibilityIdentifier = scenario
        return cell
    }
}

// MARK: - Tableview delegate

extension ScenarioListController {
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scenario = searchController.isActive ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row]
        Spoofer.startReplaying(scenarioName: scenario, inSuite: suiteName)
        searchController.isActive = false
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: SegueIdentifier.showResponses.rawValue, sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let scenarioToDelete = scenarioNames[indexPath.row]
            _ = DataStore.delete(scenarioName: scenarioToDelete, suite: suiteName)
            loadScenarios()

        default: break
        }
    }
}

// MARK: - Search controller delegate

extension ScenarioListController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        defer {
            tableView.reloadData()
        }

        guard let searchText = searchController.searchBar.text?.lowercased() else {
            filteredScenarios = scenarioNames
            return
        }

        filteredScenarios = scenarioNames.filter { $0.lowercased().contains(searchText) }
    }
}
