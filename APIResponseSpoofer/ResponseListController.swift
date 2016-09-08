//
//  ResponseListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/13/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit

class ResponseListController: UITableViewController {
    
    var scenarioName = ""
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
        controller.searchBar.barTintColor = UIColor.lightGray
        controller.searchBar.tintColor = UIColor.black
        controller.dimsBackgroundDuringPresentation = true
        return controller
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: expandText, style: .plain, target: self, action: #selector(ResponseListController.toggleRowHeight(_:)))
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
    
    // MARK: Utility methods
    
    func loadScenario() {
        Store.loadScenario(scenarioName, callback: { [weak self] success, scenario in
            if success {
                self?.allResponses = scenario.apiResponses
                self?.tableView.reloadData()
            }
            }, errorHandler: { error in
                
        })
    }
    
    func toggleRowHeight(_ sender: UIBarButtonItem) {
        if sender.title == expandText {
            sender.title = collapseText
            cellHeight = UITableViewAutomaticDimension
        } else {
            sender.title = expandText
            cellHeight = 44.0
        }
        searchController.isActive = false
        tableView.reloadData()
    }
    
}

// MARK: - Tableview datasource

extension ResponseListController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredResponses.count : allResponses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestURLCell", for: indexPath)
        let response = searchController.isActive ? filteredResponses[indexPath.row] : allResponses[indexPath.row]
        cell.textLabel?.text = response.requestURL.absoluteString
        return cell
    }
    
}

// MARK: - Tableview delegate

extension ResponseListController {
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            case .delete:
                // Remove the response from local array
                allResponses.remove(at: (indexPath as NSIndexPath).row)
                // Create a new scenario based on the responses and save it to disk
                let scenario = Scenario(name: scenarioName)
                scenario.apiResponses = allResponses
                Store.saveScenario(scenario, callback: { [weak tableView] success, savedScenario in
                        DispatchQueue.main.async(execute: {
                            // Update the tableview upon succesful scenario updation
                            tableView?.deleteRows(at: [indexPath], with: .automatic)
                            // If Spoofer was already in replay mode, update the scenario with the updated version
                            if Spoofer.spoofedScenario != nil {
                                Spoofer.spoofedScenario = savedScenario
                            }
                        })
                    }, errorHandler: { [weak tableView] error in
                        // Cause a tableview reload if scenario creation failed due to some reason
                        tableView?.reloadData()
                })
            
            case .insert: break
            case .none: break
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
            return $0.requestURL.absoluteString.contains(searchText.lowercased())
        }
    }
    
}
