//
//  SwitchWithTextViewModel.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

struct SwitchWithTextViewModel: SwitchWithTextViewPresentable {
    var model: [SpooferConfigurationType : AnyObject]
}

// MARK: TextPresentable Conformance
extension SwitchWithTextViewModel {
    var text: String {
        guard let configType = model.keys.first else { return "" }
        return configType.rawValue
    }
    
    private var packedData: Any {
        guard let data = model.values.first else { return "" }
        return data
    }
    
    var modelIsBoolean: Bool {
        return packedData is Bool
    }
}

// MARK: SwitchPresentable Conformance
extension SwitchWithTextViewModel {
    var switchOn: Bool { return modelIsBoolean }
    var switchHidden: Bool { return modelIsBoolean == false }
    
    func onSwitchTogleOn(on: Bool) {
        if on {
            print("On")
        } else {
            print("Off")
        }
    }
}

// MARK: NavigationPresentable Conformance
extension SwitchWithTextViewModel {
    var allowCellSelection: Bool { return modelIsBoolean == false }
    var disclosureHidden: Bool { return modelIsBoolean }
}

extension SwitchWithTextViewModel {
    var configurations: [String] {
        guard let configs = packedData as? [String] else { return [String]() }
        return configs
    }
}