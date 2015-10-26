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
    
    private lazy var scenarioNames:[String] = {
        return Store.allScenarioNames() as [String]
        }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.barTintColor = UIColor.lightGrayColor()
        controller.searchBar.tintColor = UIColor.blackColor()
        controller.searchBar.scopeButtonTitles = ["Name","Date"]
        controller.searchBar.delegate = self
        return controller
    }()
    
    var filteredScenarios = [String]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.active ? filteredScenarios.count : scenarioNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScenarioCell", forIndexPath: indexPath)
        let scenario: String = searchController.active ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
        cell.textLabel?.text = scenario
        cell.accessibilityIdentifier = scenario
        return cell
    }
    
    @IBAction func cancel(sender: AnyObject) {
        searchController.active = false
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Tableview Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let scenario = searchController.active ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
        Spoofer.startReplaying(scenarioName: scenario)
        searchController.active = false
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ScenarioListController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // searchBar.selectedScopeButtonIndex
        if searchController.searchBar.text?.characters.count > 0 {
            filteredScenarios = scenarioNames.filter({ scenario -> Bool in
                return scenario.lowercaseString.rangeOfString(searchController.searchBar.text!.lowercaseString) != nil
            })
        } else {
            filteredScenarios = scenarioNames
        }
        self.tableView.reloadData()
    }
}

extension ScenarioListController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.tableView.reloadData()
    }
}
