//
//  ResponseCell.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 1/26/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import UIKit

class ResponseCell: UITableViewCell {

    @IBOutlet weak var reponseImageView: UIImageView!
    @IBOutlet weak var urlLabel: UILabel!

    override func prepareForReuse() {
        reponseImageView.image = nil
        urlLabel.text = ""
    }
}
