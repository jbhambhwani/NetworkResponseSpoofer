//
//  ResponseCell.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 1/26/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import UIKit

final class ResponseCell: UITableViewCell {
    @IBOutlet var reponseImageView: UIImageView!
    @IBOutlet var urlLabel: UILabel!

    override func prepareForReuse() {
        reponseImageView.image = nil
        urlLabel.text = ""
    }
}
