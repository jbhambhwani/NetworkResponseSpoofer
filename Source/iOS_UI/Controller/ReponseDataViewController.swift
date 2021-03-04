//
//  ReponseDataViewController.swift
//  NetworkResponseSpoofer
//
//  Created by Jaikumar Bhambhwani on 23/06/2020.
//

import UIKit

class ReponseDataViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var copyButton: UIBarButtonItem!
    var data: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = data {
            dataLabel.text = data
            copyButton.isEnabled = true
        }
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = data
    }
}
