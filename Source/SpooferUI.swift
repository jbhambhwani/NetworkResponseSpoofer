//
//  SpooferUI.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/14/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import UIKit

public extension Spoofer {
    
    /**
     Starts recording a new scenario from a specific view controller.
     
     - parameter sourceViewController: The view controller from which the record popup UI will be presented from
     
     - Note: A popup will appear asking the user to name the scenario, before recording starts. Use this method if you need to manually provide the scenario name
     */
    class func startRecording(inViewController sourceViewController: UIViewController?) {
        
        guard let sourceViewController = sourceViewController else { return }
        
        // When a view controller was passed in, use it to display an alert controller asking for a scenario name
        let alertController = UIAlertController(title: "Create Scenario", message: "Enter a scenario name to save the requests & responses", preferredStyle: .alert)
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [unowned alertController](_) in
            if let textField = alertController.textFields?.first, let scenarioName = textField.text {
                _ = startRecording(scenarioName: scenarioName)
            }
        }
        createAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            SpooferRecorder.stopIntercept()
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter scenario name"
            textField.autocapitalizationType = .sentences
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                createAction.isEnabled = textField.text != ""
            }
        }
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        
        sourceViewController.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Show recorded scenarios in Documents folder as a list for the user to select and start replay (Replay selection UI)
     
     - parameter sourceViewController: The view controller from which to present the replay selection UI
     
     - Note: The replay selection UI also has few other roles.
     - It allows configuring the spoofer using a config button the nav bar, allowing to tweak whitelist/blacklist/query parameters, normalization etc
     - It shows the list of pre-recorded scenarios in the folder. Tapping a scenario starts replay directly and dismissed the UI
     - It allows diving deeper into the scenario by tapping the info button along the right of each scenario. This lists the url's which have recorded responses in the scenario.
     */
    class func showRecordedScenarios(inViewController sourceViewController: UIViewController?) {
        guard let sourceViewController = sourceViewController else { return }
        
        func spooferStoryBoard() -> UIStoryboard {
            let frameworkBundle = Bundle(for: Spoofer.self)
            let storyBoard = UIStoryboard(name: "Spoofer", bundle: frameworkBundle)
            return storyBoard
        }
        
        let scenarioListController = spooferStoryBoard().instantiateViewController(withIdentifier: ScenarioListController.identifier)
        sourceViewController.present(scenarioListController, animated: true, completion: nil)
    }

}
