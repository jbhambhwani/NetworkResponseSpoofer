//
//  ScenarioListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit

class ScenarioListController: UITableViewController {

    static let identifier = "ScenarioListNavController"

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedScenarioName = ""
    }

    deinit {
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            // Fallback on earlier versions
            searchController.view.removeFromSuperview()
        }
    }

    @IBAction func cancel(_: AnyObject) {
        searchController.isActive = false
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let responseListController = segue.destination as? ResponseListController, let indexPath = sender as? IndexPath else { return }
        selectedScenarioName = searchController.isActive ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row]
        responseListController.scenarioName = selectedScenarioName
    }

    // MARK: - Private properties

    fileprivate var filteredScenarios = [String]()
    fileprivate var selectedScenarioName = ""

    fileprivate lazy var scenarioNames: [String] = {
        return DataStore.allScenarioNames(suite: Spoofer.suiteName)
    }()

    fileprivate lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.searchBar.sizeToFit()
        controller.searchBar.barTintColor = UIColor.lightGray
        controller.searchBar.tintColor = UIColor.black
        controller.dimsBackgroundDuringPresentation = true
        return controller
    }()
}

// MARK: - Tableview datasource

extension ScenarioListController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        Spoofer.startReplaying(scenarioName: scenario)
        searchController.isActive = false
        navigationController?.dismiss(animated: true, completion: nil)
    }

    override func tableView(_: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "showResponses", sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        switch editingStyle {
        case .delete:
            let scenarioToDelete = scenarioNames.remove(at: indexPath.row)
            let deletionResult = DataStore.delete(scenarioName: scenarioToDelete, suite: Spoofer.suiteName)

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

        guard let searchText = searchController.searchBar.text else {
            filteredScenarios = scenarioNames
            return
        }

        filteredScenarios = scenarioNames.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
}
