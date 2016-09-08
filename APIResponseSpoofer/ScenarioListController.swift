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

    @IBAction func cancel(_ sender: AnyObject) {
        searchController.isActive = false
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let responseListController = segue.destination as? ResponseListController, let indexPath = sender as? IndexPath else { return }
        selectedScenarioName = searchController.isActive ? filteredScenarios[(indexPath as NSIndexPath).row] : scenarioNames[indexPath.row] as String
        responseListController.scenarioName = selectedScenarioName
    }
    
    // MARK: - Private properties
    
    private var filteredScenarios = [String]()
    private var selectedScenarioName = ""
    
    private lazy var scenarioNames: [String] = {
        return Store.allScenarioNames()
    }()
    
    private lazy var searchController: UISearchController = {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScenarioCell", for: indexPath)
        let scenario: String = searchController.isActive ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
        cell.textLabel?.text = scenario
        cell.accessibilityIdentifier = scenario
        return cell
    }
    
}

// MARK: - Tableview delegate

extension ScenarioListController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let scenario = searchController.isActive ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
        Spoofer.startReplaying(scenarioName: scenario)
        searchController.isActive = false
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "showResponses", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            // Remove response from local array
            let scenarioToDelete = scenarioNames.remove(at: (indexPath as NSIndexPath).row)
            Store.deleteScenario(scenarioToDelete, callback: { success in
                    // Update the tableview upon succesful scenario deletion
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }, errorHandler: { error in
                     // Cause a tableview reload if scenario creation failed due to some reason
                    tableView.reloadData()
            })
            
        case .insert: break
        case .none: break
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
