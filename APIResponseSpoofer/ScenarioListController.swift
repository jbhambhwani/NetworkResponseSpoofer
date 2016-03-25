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
        // TODO: Fix this with Swift 2.3 availability check. Make not available for TV
        // tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
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

    @IBAction func cancel(sender: AnyObject) {
        searchController.active = false
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let responseListController = segue.destinationViewController as? ResponseListController, indexPath = sender as? NSIndexPath else { return }
        selectedScenarioName = searchController.active ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
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
        controller.searchBar.barTintColor = UIColor.lightGrayColor()
        controller.searchBar.tintColor = UIColor.blackColor()
        // TODO: Fix this with Swift 2.3 availability check. Make not available for TV
        // controller.dimsBackgroundDuringPresentation = true
        return controller
    }()
}

// MARK: - Tableview datasource

extension ScenarioListController {
    
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
    
}

// MARK: - Tableview delegate

extension ScenarioListController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let scenario = searchController.active ? filteredScenarios[indexPath.row] : scenarioNames[indexPath.row] as String
        Spoofer.startReplaying(scenarioName: scenario)
        searchController.active = false
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showResponses", sender: indexPath)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch editingStyle {
        case .Delete:
            // Remove response from local array
            let scenarioToDelete = scenarioNames.removeAtIndex(indexPath.row)
            Store.deleteScenario(scenarioToDelete, callback: { success in
                    // Update the tableview upon succesful scenario deletion
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }, errorHandler: { error in
                     // Cause a tableview reload if scenario creation failed due to some reason
                    tableView.reloadData()
            })
            
        case .Insert: break
        case .None: break
        }
    }
    
}

// MARK: - Search controller delegate

extension ScenarioListController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        defer {
            tableView.reloadData()
        }
        
        guard let searchText = searchController.searchBar.text else {
            filteredScenarios = scenarioNames
            return
        }
        
        filteredScenarios = scenarioNames.filter { $0.lowercaseString.containsString(searchText.lowercaseString) }
    }

}