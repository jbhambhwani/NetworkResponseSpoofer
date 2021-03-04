//
//  DataStore.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import os
import RealmSwift

public let defaultSuiteName = "Default"

/// Errors thrown from Realm Datastore
public enum StoreError: Int, Error {
    case scenarioNotFound
    case unableToSaveScenario
    case unableToResetScenario
    case unableToSaveResponse
    case unableToUpdateResponse
    case unableToDeleteScenario

    var localizedDescription: String {
        switch self {
        case .scenarioNotFound:
            return "Scenario Not Found"
        case .unableToSaveScenario:
            return "Unable to save scenario"
        case .unableToResetScenario:
            return "Unable to reset scenario"
        case .unableToSaveResponse:
            return "Unable to save response"
        case .unableToUpdateResponse:
            return "Unable to update response"
        case .unableToDeleteScenario:
            return "Unable to delete scenario"
        }
    }
}

public protocol Store {
    // Migration
    func runMigrations(newSchemaVersion: UInt64)
    // Scenario
    func allScenarioNames(suite: String) -> [String]
    func save(scenario: Scenario, suite: String) -> Result<Scenario>
    func load(scenarioName: String, suite: String) -> Result<Scenario>
    func reset(scenario: Scenario) -> Result<Bool>
    func delete(scenarioName: String, suite: String) -> Result<Bool>
    // Response
    func save(response: NetworkResponse, scenarioName: String, suite: String) -> Result<NetworkResponse>
    func markAsServed(response: NetworkResponse) -> Result<Bool>
    func delete(response: NetworkResponse, scenarioName: String, suite: String) -> Result<Bool>
}

public enum DataStore {
    public static func runMigrations(newSchemaVersion: UInt64) {
        return RealmStore.sharedInstance.runMigrations(newSchemaVersion: newSchemaVersion)
    }

    public static func allScenarioNames(suite: String) -> [String] {
        return RealmStore.sharedInstance.allScenarioNames(suite: suite)
    }

    public static func save(scenario: Scenario, suite: String) -> Result<Scenario> {
        return RealmStore.sharedInstance.save(scenario: scenario, suite: suite)
    }

    public static func load(scenarioName: String, suite: String) -> Result<Scenario> {
        return RealmStore.sharedInstance.load(scenarioName: scenarioName, suite: suite)
    }

    public static func delete(scenarioName: String, suite: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(scenarioName: scenarioName, suite: suite)
    }

    public static func save(response: NetworkResponse, scenarioName: String, suite: String) -> Result<NetworkResponse> {
        return RealmStore.sharedInstance.save(response: response, scenarioName: scenarioName, suite: suite)
    }

    public static func reset(scenario: Scenario) -> Result<Bool> {
        return RealmStore.sharedInstance.reset(scenario: scenario)
    }

    public static func markAsServed(response: NetworkResponse) -> Result<Bool> {
        return RealmStore.sharedInstance.markAsServed(response: response)
    }

    public static func delete(response: NetworkResponse, scenarioName: String, suite: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(response: response, scenarioName: scenarioName, suite: suite)
    }
}

private struct RealmStore {
    static let sharedInstance = RealmStore()

    var realm: Realm {
        do {
            return try Realm()
        } catch {
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("Unable to instanciate Realm store", log: .database, type: .error)
            }
            preconditionFailure("Unable to instanciate Realm store")
        }
    }

    func setDefaultRealmForSuite(suiteName: String) {
        var config = Realm.Configuration.defaultConfiguration
        config.fileURL = FileManager.spooferDocumentsDirectory.appendingPathComponent("\(suiteName).\(realmFileExtension)")
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config

        if Spoofer.suiteName != suiteName, let path = Realm.Configuration.defaultConfiguration.fileURL {
            postNotification("Datastore Path: \(path)")
            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("Datastore Path: %s", log: .database, path.absoluteString)
            }
        }
    }
}

extension RealmStore: Store {
    func runMigrations(newSchemaVersion: UInt64) {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: newSchemaVersion,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, oldSchemaVersion in
                switch oldSchemaVersion {
                case 0, 1:
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                    // Read more about the migration process in Realm documentation
                    break
                default:
                    break
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }

    // MARK: - Scenario Management

    private func getScenario(_ name: String, suite: String) -> Scenario? {
        setDefaultRealmForSuite(suiteName: suite)
        return realm.objects(Scenario.self).filter("name == %@", name).first
    }

    public func allScenarioNames(suite: String) -> [String] {
        setDefaultRealmForSuite(suiteName: suite)
        return realm.objects(Scenario.self).compactMap { $0.name }
    }

    func save(scenario: Scenario, suite: String) -> Result<Scenario> {
        setDefaultRealmForSuite(suiteName: suite)
        do {
            try realm.write {
                realm.add(scenario, update: .all)
            }

            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("Saved scenario: %s, Suite: %s", log: .database, type: .info, scenario.name, suite)
            }

            return .success(scenario)
        } catch {
            return .failure(StoreError.unableToSaveScenario)
        }
    }

    func load(scenarioName: String, suite: String) -> Result<Scenario> {
        guard let scenario = getScenario(scenarioName, suite: suite) else {
            return .failure(StoreError.scenarioNotFound)
        }

        return .success(scenario)
    }

    func reset(scenario: Scenario) -> Result<Bool> {
        // Reset the served flag on all responses of a scenario
        do {
            try realm.write {
                scenario.networkResponses.forEach { $0.servedToClient = false }
            }
            return .success(true)
        } catch {
            return .failure(StoreError.unableToResetScenario)
        }
    }

    func delete(scenarioName: String, suite: String) -> Result<Bool> {
        guard let scenario = getScenario(scenarioName, suite: suite) else {
            return .failure(StoreError.scenarioNotFound)
        }

        do {
            try realm.write {
                scenario.networkResponses.forEach { realm.delete($0.headerFields) }
                realm.delete(scenario.networkResponses)
                realm.delete(scenario)
            }

            if #available(iOS 12.0, OSX 10.14, *) {
                os_log("Deleted scenario: %s, Suite: %s", log: .database, type: .info, scenarioName, suite)
            }

            return .success(true)
        } catch {
            return .failure(StoreError.unableToDeleteScenario)
        }
    }

    // MARK: - Response Management

    func save(response: NetworkResponse, scenarioName: String, suite: String) -> Result<NetworkResponse> {
        guard let scenario = getScenario(scenarioName, suite: suite) else { return .failure(StoreError.scenarioNotFound) }

        do {
            try realm.write {
                scenario.networkResponses.append(response)
            }
            return .success(response)
        } catch {
            return .failure(StoreError.unableToSaveResponse)
        }
    }

    func markAsServed(response: NetworkResponse) -> Result<Bool> {
        do {
            try realm.write {
                response.servedToClient = true
            }
            return .success(true)
        } catch {
            return .failure(StoreError.unableToUpdateResponse)
        }
    }

    func delete(response: NetworkResponse, scenarioName: String, suite: String) -> Result<Bool> {
        guard let scenario = getScenario(scenarioName, suite: suite) else { return .failure(StoreError.scenarioNotFound) }

        do {
            try realm.write {
                if let responseToDelete = scenario.networkResponses.first(where: { $0 == response }) {
                    realm.delete(responseToDelete.headerFields)
                    realm.delete(responseToDelete)
                }
            }
            return .success(true)
        } catch {
            return .failure(StoreError.unableToSaveResponse)
        }
    }
}
