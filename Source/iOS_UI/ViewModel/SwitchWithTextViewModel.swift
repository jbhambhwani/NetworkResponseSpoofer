//
//  SwitchWithTextViewModel.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 3/16/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

struct SwitchWithTextViewModel: SwitchWithTextViewPresentable {
    var model: [SpooferConfigurationType: Any]
}

// MARK: - TextPresentable Conformance

extension SwitchWithTextViewModel {
    var title: String {
        return configType.rawValue
    }

    var subtitle: String {
        return configType.description
    }

    private var configType: SpooferConfigurationType {
        guard let configType = model.keys.first else { return .blank }
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

    var switchHidden: Bool { return !modelIsBoolean }

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
    var configurations: [Any] {
        get {
            if let configs = packedData as? [String] {
                return configs
            } else if let configs = packedData as? [URLPathRangeReplacement] {
                return configs
            } else {
                return []
            }
        }

        set {
            // Based on current configuration, Update the Spoofer instance with new setting
            switch configType {
            case .spoofedHosts:
                Spoofer.hostNamesToSpoof = newValue as! [String]
            case .ignoredHosts:
                Spoofer.hostNamesToIgnore = newValue as! [String]
            case .ignoredPaths:
                Spoofer.pathsToIgnore = newValue as! [String]
            case .normalizedSubdomains:
                Spoofer.subDomainsToNormalize = newValue as! [String]
            case .normalizedQueryParameters:
                Spoofer.queryParametersToNormalize = newValue as! [String]
            case .normalizedPathComponents:
                Spoofer.pathComponentsToNormalize = newValue as! [String]
            case .replacePathRanges:
                Spoofer.pathRangesToReplace = newValue as! [URLPathRangeReplacement]
            default:
                assertionFailure("Unhandled case")
            }

            model[configType] = newValue
        }
    }
}
