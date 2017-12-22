//
//  ScenarioListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit

class ScenarioListController: UITableViewController {

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
        scenarioNames = DataStore.allScenarioNames(suite: suiteName)
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

    fileprivate var scenarioNames = [String]()
    fileprivate var filteredScenarios = [String]()
    fileprivate var selectedScenarioName = ""

    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.searchBar.backgroundColor = .darkGray
        controller.hidesNavigationBarDuringPresentation = false
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        switch editingStyle {
        case .delete:
            let scenarioToDelete = scenarioNames.remove(at: indexPath.row)
            let deletionResult = DataStore.delete(scenarioName: scenarioToDelete, suite: suiteName)

            switch deletionResult {
            case .success:
                // Update the tableview upon succesful scenario deletion
                tableView.deleteRows(at: [indexPath], with: .automatic)
            case .failure:
                // Cause a tableview reload if scenario creation failed due to some reason
                tableView.reloadData()
            }

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
