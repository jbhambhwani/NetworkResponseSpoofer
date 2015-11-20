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
        controller.searchBar.delegate = self
        return controller
    }()
    
    private var filteredScenarios = [String]()
    private var selectedScenarioName: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        selectedScenarioName = ""
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
    
    // Navigation
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showResponses", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let responseListController = segue.destinationViewController as? ResponseListController, indexPath = sender as? NSIndexPath else { return }
        selectedScenarioName = searchController.active ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
        responseListController.scenarioName = selectedScenarioName
    }
}

extension ScenarioListController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
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
