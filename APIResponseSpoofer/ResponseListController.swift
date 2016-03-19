//
//  ResponseListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/13/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit

class ResponseListController: UITableViewController {
    
    var scenarioName: String = ""
    var cellHeight: CGFloat = 44.0
    let expandText = "Expand"
    let collapseText = "Collapse"
    
    private var allResponses = [APIResponse]()
    private var filteredResponses = [APIResponse]()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.delegate = self
        controller.searchBar.sizeToFit()
        controller.searchBar.barTintColor = UIColor.lightGrayColor()
        controller.searchBar.tintColor = UIColor.blackColor()
        return controller
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: expandText, style: .Plain, target: self, action: "toggleRowHeight:")
        // Load the responses for the passed in scenario
        if scenarioName.characters.count > 0 {
            loadScenario()
        }
    }
    
    deinit {
        if #available(iOS 9.0, *) {
            searchController.loadViewIfNeeded()
        } else {
            // Fallback on earlier versions
            searchController.view.removeFromSuperview()
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.active ? filteredResponses.count : allResponses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RequestURLCell", forIndexPath: indexPath)
        let response = searchController.active ? filteredResponses[indexPath.row] : allResponses[indexPath.row]
        cell.textLabel?.text = response.requestURL.absoluteString
        return cell
    }
    
    // Tableview Delegate
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    // MARK: Utility methods
    
    func loadScenario() {
        Store.loadScenario(scenarioName, callback: { success, scenario in
            if success {
                self.allResponses = scenario.apiResponses
                self.tableView.reloadData()
            }
            }, errorHandler: { error in
                
        })
    }
    
    func toggleRowHeight(sender: UIBarButtonItem) {
        if sender.title == expandText {
            sender.title = collapseText
            cellHeight = UITableViewAutomaticDimension
        } else {
            sender.title = expandText
            cellHeight = 44.0
        }
        searchController.active = false
        tableView.reloadData()
    }
    
}

// MARK: - Search controller delegate

extension ResponseListController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        defer {
            self.tableView.reloadData()
        }
        
        guard let searchText = searchController.searchBar.text else {
            filteredResponses = allResponses
            return
        }
        
        filteredResponses = allResponses.filter{ $0.requestURL.absoluteString.containsString(searchText.lowercaseString) }
    }
    
}
