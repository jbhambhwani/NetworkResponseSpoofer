//
//  ReponseDetailsViewController.swift
//  NetworkResponseSpoofer
//
//  Created by Jaikumar Bhambhwani on 23/06/2020.
//

import Foundation
#if !COCOAPODS
    import NetworkResponseSpoofer
#endif
import UIKit

class ReponseDetailsViewController: UIViewController {

    var response: NetworkResponse?{
        didSet {
            guard view.window != nil else { return  }
            configureWithResponse()
        }
    }
    
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var httpMethodLabel: UILabel!
    @IBOutlet weak var reponseCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWithResponse()
    }
    
    // MARK: - Setup
    
    func configureWithResponse() {
        urlLabel.text = response?.requestURL
        httpMethodLabel.text = response?.httpMethod
        reponseCodeLabel.text = "\(response?.statusCode ?? -1)"
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let data = sender as? String?, let destination = segue.destination as? ReponseDataViewController {
            destination.data = data
        }
    }

    // MARK: - Events
    
    @IBAction func showDetails(_ sender: UIButton) {
        
        switch sender.tag {
        case 100:
            perform(segue: StoryboardSegue.Spoofer.showReponseData, sender: response?.requestQueryParams)
        case 101:
            perform(segue: StoryboardSegue.Spoofer.showReponseData, sender: response?.requestHeaders)
        case 102:
            perform(segue: StoryboardSegue.Spoofer.showReponseData, sender: response?.requestBody)
        case 103:
            perform(segue: StoryboardSegue.Spoofer.showReponseData, sender: response?.responseHeaders)
        case 104:
            perform(segue: StoryboardSegue.Spoofer.showReponseData, sender: response?.responseBody)
        default:
            break
        }
    }
}
