//
//  RecordTableViewController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/19/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import UIKit

final class RecordTableViewController: UITableViewController {

    static let identifier = "RecordNavigationController"

    @IBOutlet var scenarioNameTextField: UITextField!
    @IBOutlet var startRecordingButton: UIButton!
    @IBOutlet var suiteNameLabel: UILabel!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        scenarioNameTextField.becomeFirstResponder()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: scenarioNameTextField, queue: OperationQueue.main) { [weak self] _ in
            guard let `self` = self else { return }
            self.startRecordingButton.isEnabled = self.scenarioNameTextField.text != ""
            self.startRecordingButton.backgroundColor = self.startRecordingButton.isEnabled ? UIColor.black : UIColor.lightGray
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(scenarioNameTextField)
    }

    // MARK: - User Actions

    @IBAction func cancelPressed() {
        SpooferRecorder.stopIntercept()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func startRecordingPressed() {
        guard let scenarioName = scenarioNameTextField.text,
            let suiteName = suiteNameLabel.text,
            Validator.validateNotEmpty(stringArray: [scenarioName, suiteName]) else { return }

        Spoofer.startRecording(scenarioName: scenarioName, inSuite: suiteName)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func backgroundTap(_: UITapGestureRecognizer) {
        scenarioNameTextField.resignFirstResponder()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        if segue.destination is SuiteListController {
            segue.destination.navigationItem.leftBarButtonItem = nil
        }
    }

    @IBAction func unwind(toRecordViewController segue: UIStoryboardSegue) {
        if let destination = segue.source as? SuiteListController {
            suiteNameLabel.text = destination.suiteName
        }
    }
}

extension RecordTableViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_: UITextField) -> Bool {
        startRecordingPressed()
        return true
    }
}
