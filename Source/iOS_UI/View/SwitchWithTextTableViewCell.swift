//
//  SwitchWithTextTableViewCell.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import UIKit

// protocol composition
// based on the UI components in the cell
typealias SwitchWithTextViewPresentable = TextPresentable & SwitchPresentable & NavigationPresentable & DataPresentable

final class SwitchWithTextTableViewCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var switchToggle: UISwitch!

    private(set) var presenter: SwitchWithTextViewPresentable?

    // configure with something that conforms to the composed protocol
    func configure(withPresenter presenter: SwitchWithTextViewPresentable) {
        self.presenter = presenter

        // configure the UI components
        titleLabel.text = presenter.title
        subtitleLabel.text = presenter.subtitle
        switchToggle.isOn = presenter.switchOn
        switchToggle.isHidden = presenter.switchHidden
        accessoryType = presenter.disclosureHidden ? .none : .disclosureIndicator
        selectionStyle = presenter.allowCellSelection ? .default : .none
    }

    @IBAction func onSwitchToggle(_ sender: UISwitch) {
        presenter?.onSwitchTogleOn(sender.isOn)
    }
}
