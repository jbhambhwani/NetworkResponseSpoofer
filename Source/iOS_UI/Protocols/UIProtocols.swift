//
//  UIProtocols.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

protocol TextPresentable {
    var title: String { get }
    var subtitle: String { get }
}

protocol SwitchPresentable {
    var switchOn: Bool { get }
    var switchHidden: Bool { get }
    func onSwitchToggle(_ value: Bool)
}

protocol NavigationPresentable {
    var disclosureHidden: Bool { get }
    var allowCellSelection: Bool { get }
}

protocol DataPresentable {
    var configurations: [Any] { get set }
}
