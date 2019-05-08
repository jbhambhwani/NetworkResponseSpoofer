//
//  DataStore.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

public let defaultSuiteName = "Default"

/// Errors thrown from Realm Datastore
public enum StoreError: Int, Error {
    case scenarioNotFound
    case unableToSaveScenario
    case unableToSaveResponse
    case unableToDeleteScenario

    var localizedDescription: String {
        switch self {
        case .scenarioNotFound:
            return "Scenario Not Found"
        case .unableToSaveScenario:
            return "Unable to save scenario"
        case .unableToSaveResponse:
            return "Unable to save response"
        case .unableToDeleteScenario:
            return "Unable to delete scenario"
        }
    }
}

public protocol Store {
    // Migration
    func runMigrations()
    // Scenario
    func allScenarioNames(suite: String) -> [String]
    func save(scenario: Scenario, suite: String) -> Result<Scenario>
    func load(scenarioName: String, suite: String) -> Result<Scenario>
    func delete(scenarioName: String, suite: String) -> Result<Bool>
    // Response
    func save(response: NetworkResponse, scenarioName: String, suite: String) -> Result<NetworkResponse>
    func delete(response: NetworkResponse, scenarioName: String, suite: String) -> Result<Bool>
}

public enum DataStore {
    public static func runMigrations() {
        return RealmStore.sharedInstance.runMigrations()
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

    public static func delete(response: NetworkResponse, scenarioName: String, suite: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(response: response, scenarioName: scenarioName, suite: suite)
    }
}

private struct RealmStore {
    static let sharedInstance = RealmStore()

    var realm: Realm { return try! Realm() }

    func setDefaultRealmForSuite(suiteName: String) {
        var config = Realm.Configuration.defaultConfiguration
        config.fileURL = FileManager.spooferDocumentsDirectory.appendingPathComponent("\(suiteName).\(realmFileExtension)")
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config

        if Spoofer.suiteName != suiteName {
            print("Datastore Path: \(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        }
    }
}

extension RealmStore: Store {
    func runMigrations() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,

            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { _, oldSchemaVersion in
                switch oldSchemaVersion {
                case 0:
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
                realm.add(scenario, update: true)
            }
            return .success(scenario)
        } catch {
            return .failure(StoreError.unableToSaveScenario)
        }
    }

    func load(scenarioName: String, suite: String) -> Result<Scenario> {
        guard let scenario = getScenario(scenarioName, suite: suite) else { return .failure(StoreError.scenarioNotFound) }
        return .success(scenario)
    }

    func delete(scenarioName: String, suite: String) -> Result<Bool> {
        guard let scenario = getScenario(scenarioName, suite: suite) else { return .failure(StoreError.scenarioNotFound) }

        do {
            try realm.write {
                scenario.networkResponses.forEach { realm.delete($0.headerFields) }
                realm.delete(scenario.networkResponses)
                realm.delete(scenario)
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
