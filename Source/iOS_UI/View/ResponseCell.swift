//
//  ResponseCell.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 1/26/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import Foundation
import NetworkResponseSpoofer
import UIKit

final class ResponseCell: UITableViewCell {
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var urlLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet var mimeTypeLabel: UILabel!

    func configure(with response: NetworkResponse) {
        statusLabel.text = String(response.statusCode)
        mimeTypeLabel.text = response.mimeType

        let part1 = NSAttributedString(string: response.httpMethod,
                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)])
        let part2 = NSAttributedString(string: response.requestURL,
                                       attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)])
        let fullText = NSMutableAttributedString()
        fullText.append(part1)
        fullText.append(NSAttributedString(string: "  "))
        fullText.append(part2)
        urlLabel.attributedText = fullText

        let totalBytes = Int64(response.data.count)
        sizeLabel.text = ResponseCell.byteFormatter.string(fromByteCount: totalBytes)

        updateStatusColor(response: response)
    }

    override func prepareForReuse() {
        statusLabel.textColor = .black
        statusLabel.text = ""
        urlLabel.text = ""
        sizeLabel.text = ""
        mimeTypeLabel.text = ""
    }

    static let byteFormatter = ByteCountFormatter()

    private func updateStatusColor(response: NetworkResponse) {
        switch response.statusCode {
        case 200 ... 299:
            statusLabel.textColor = rgb(0, 144, 81)
        case 300 ... 399:
            statusLabel.textColor = rgb(255, 147, 0)
        case 400 ... 599:
            statusLabel.textColor = rgb(255, 38, 0)
        default:
            statusLabel.textColor = .black
        }
    }
}

private func rgb(_ red: Int, _ green: Int, _ blue: Int) -> UIColor {
    return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
}
