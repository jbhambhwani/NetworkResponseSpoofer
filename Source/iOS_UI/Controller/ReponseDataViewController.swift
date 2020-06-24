//
//  ReponseDataViewController.swift
//  NetworkResponseSpoofer
//
//  Created by Jaikumar Bhambhwani on 23/06/2020.
//

import UIKit

class ReponseDataViewController: UIViewController {

    @IBOutlet weak var dataLabel: UILabel!
    var data: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        dataLabel.text = data
    }
    
    @IBAction func copyButtonTapped(_ sender: Any) {
        UIPasteboard.general.string = data
    }
}
