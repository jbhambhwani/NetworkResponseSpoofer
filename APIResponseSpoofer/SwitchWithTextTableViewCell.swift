//
//  SwitchWithTextTableViewCell.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

// protocol composition
// based on the UI components in the cell
typealias SwitchWithTextViewPresentable = protocol<TextPresentable, SwitchPresentable, NavigationPresentable, DataPresentable>

class SwitchWithTextTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var switchToggle: UISwitch!
    
    private(set) var presenter: SwitchWithTextViewPresentable?
    
    // configure with something that conforms to the composed protocol
    func configure(withPresenter presenter: SwitchWithTextViewPresentable) {
        self.presenter = presenter
        
        // configure the UI components
        label.text = presenter.text
        switchToggle.on = presenter.switchOn
        switchToggle.hidden = presenter.switchHidden
        accessoryType = presenter.disclosureHidden ? .None : .DisclosureIndicator
        selectionStyle = presenter.allowCellSelection ? .Default : .None
    }
    
    @IBAction func onSwitchToggle(sender: UISwitch) {
        presenter?.onSwitchTogleOn(sender.on)
    }
}
