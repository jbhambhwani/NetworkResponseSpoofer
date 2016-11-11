//
//  SwitchWithTextViewModel.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

struct SwitchWithTextViewModel: SwitchWithTextViewPresentable {
    var model: [SpooferConfigurationType : Any]
}

// MARK: - TextPresentable Conformance

extension SwitchWithTextViewModel {
    
    var title: String {
        return configType.rawValue
    }
    
    var subtitle: String {
        return configType.description
    }
    
    fileprivate var configType: SpooferConfigurationType {
        guard let configType = model.keys.first else { return .Blank }
        return configType
    }
    
    fileprivate var packedData: Any {
        guard let data = model.values.first else { return "" }
        return data
    }
    
    fileprivate var modelIsBoolean: Bool {
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
    
    func onSwitchTogleOn(_ on: Bool) {
        switch configType {
        case .queryValueNormalization:
            Spoofer.normalizeQueryValues = on
        case .acceptSelfSignedCertificate:
            Spoofer.allowSelfSignedCertificate = on
        default:
            assertionFailure("Unhandled case")
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
            case .ignoredPathComponents:
                Spoofer.pathComponentsToIgnore = newValue
            default:
                assertionFailure("Unhandled case")
            }

            model[configType] = newValue as AnyObject?
        }
    }
}
