//
//  ScenarioListController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 10/10/15.
//  Copyright © 2015 Hotwire. All rights reserved.
//

import UIKit

class ScenarioListController: UITableViewController {
    
    lazy var scenarioNames:[NSString] = {
        return Store.allScenarioNames()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenarioNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ScenarioCell", forIndexPath: indexPath)
        cell.textLabel?.text = scenarioNames[indexPath.row] as String
        return cell
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Tableview Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Spoofer.startReplaying(scenarioName: scenarioNames[indexPath.row] as String)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
