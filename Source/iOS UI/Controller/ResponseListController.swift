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
    
    fileprivate var allResponses = [APIResponse]()
    fileprivate var filteredResponses = [APIResponse]()
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.scrollsToTop = true
        tableView.tableHeaderView = searchController.searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: expandText, style: .plain, target: self, action: #selector(ResponseListController.toggleRowHeight(_:)))
        // Load the responses for the passed in scenario
        if scenarioName.characters.count > 0 {
            loadResponses()
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
    
    func loadResponses() {
        let loadResult = DataStore.load(scenarioName: scenarioName)
        switch loadResult {
        case .success(let scenario):
            allResponses = Array(scenario.apiResponses)
            tableView.reloadData()
        case .failure(_):
            break
        }
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
        cell.textLabel?.text = response.requestURL
        
        if [".png", ".jpg", ".jpeg", ".tiff", ".tif", ".gif", ".bmp", ".ico"]
            .filter({ response.requestURL.hasSuffix($0) }).count == 1 {
            cell.imageView?.image = UIImage(data: response.data)
        } else {
            cell.imageView?.image = nil
        }
        
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
                allResponses.remove(at: indexPath.row)
                let deleteResult = DataStore.delete(responseIndex: indexPath.row, scenarioName: scenarioName)
                
                switch deleteResult {
                case .success(_):
                    DispatchQueue.main.async(execute: {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    })

                case .failure(_):
                    // Cause a tableview reload if deletion failed due to some reason
                    tableView.reloadData()
                }
                
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
