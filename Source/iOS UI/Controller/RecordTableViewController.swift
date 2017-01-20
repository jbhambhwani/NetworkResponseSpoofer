//
//  RecordTableViewController.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/19/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import UIKit

class RecordTableViewController: UITableViewController {

    static let identifier = "RecordNavigationController"

    @IBOutlet weak var scenarioNameTextField: UITextField!
    @IBOutlet weak var startRecordingButton: UIButton!

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

    // MARK - User Actions

    @IBAction func cancelPressed() {
        SpooferRecorder.stopIntercept()
        dismiss(animated: true, completion: nil)
    }

    @IBAction func startRecordingPressed() {
        Spoofer.startRecording(scenarioName: scenarioNameTextField.text)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func backgroundTap(_ sender: UITapGestureRecognizer) {
        scenarioNameTextField.resignFirstResponder()
    }

}
