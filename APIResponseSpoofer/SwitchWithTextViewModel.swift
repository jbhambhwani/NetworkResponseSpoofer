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

// MARK: - TextPresentable Conformance

extension SwitchWithTextViewModel {
    
    var text: String {
        return configType.rawValue
    }
    
    private var configType: SpooferConfigurationType {
        guard let configType = model.keys.first else { return .None }
        return configType
    }
    
    private var packedData: Any {
        guard let data = model.values.first else { return "" }
        return data
    }
    
    private var modelIsBoolean: Bool {
        return packedData is Bool
    }
}

// MARK: - SwitchPresentable Conformance

extension SwitchWithTextViewModel {
    
    var switchOn: Bool {
        guard let boolValue = packedData as? Bool else { return modelIsBoolean }
        return boolValue
    }
    
    var switchHidden: Bool { return !modelIsBoolean}
    
    func onSwitchTogleOn(on: Bool) {
        switch configType {
        case .queryParameterNormalization:
            Spoofer.normalizeQueryParameters = on
        case .acceptSelfSignedCertificate:
            Spoofer.allowSelfSignedCertificate = on
        default:
            assert(false, "Unhandled case")
        }
    }
}

// MARK: - NavigationPresentable Conformance

extension SwitchWithTextViewModel {
    var allowCellSelection: Bool { return !modelIsBoolean }
    var disclosureHidden: Bool { return modelIsBoolean }
}

// MARK: - DataPresentable Conformance

extension SwitchWithTextViewModel {
    
    var configurations: [String] {
        get {
            guard let configs = packedData as? [String] else { return [String]() }
            return configs
        }
        set {
            // Based on current configuration, Update the Spoofer instance with new setting
            switch configType {
            case .spoofedHosts:
                Spoofer.hostNamesToSpoof = newValue
            case .ignoredHosts:
                Spoofer.hostNamesToIgnore = newValue
            case .ignoredSubdomains:
                Spoofer.subDomainsToIgnore = newValue
            case .ignoredQueryParameters:
                Spoofer.queryParametersToIgnore = newValue
            default:
                assert(false, "Unhandled case")
            }
            
            model[configType] = newValue
        }
    }
}
