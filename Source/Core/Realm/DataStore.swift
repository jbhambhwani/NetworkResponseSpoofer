//
//  DataStore.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

let defaultSuiteName = "Default"

/// Errors thrown from Realm Datastore
public enum StoreError: Int, Error {
    case scenarioNotFound
    case unableToSaveScenario
    case unableToSaveResponse
    case unableToDeleteScenario
}

protocol Store {
    // Scenario
    func allScenarioNames(suite: String) -> [String]
    func save(scenario: Scenario, suite: String) -> Result<Scenario>
    func load(scenarioName: String, suite: String) -> Result<Scenario>
    func delete(scenarioName: String, suite: String) -> Result<Bool>
    // Response
    func save(response: APIResponse, scenarioName: String, suite: String) -> Result<APIResponse>
    func delete(responseIndex: Int, scenarioName: String, suite: String) -> Result<Bool>
}

enum DataStore {

    static func allScenarioNames(suite: String) -> [String] {
        return RealmStore.sharedInstance.allScenarioNames(suite: suite)
    }

    static func save(scenario: Scenario, suite: String) -> Result<Scenario> {
        return RealmStore.sharedInstance.save(scenario: scenario, suite: suite)
    }

    static func load(scenarioName: String, suite: String) -> Result<Scenario> {
        return RealmStore.sharedInstance.load(scenarioName: scenarioName, suite: suite)
    }

    static func delete(scenarioName: String, suite: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(scenarioName: scenarioName, suite: suite)
    }

    static func save(response: APIResponse, scenarioName: String, suite: String) -> Result<APIResponse> {
        return RealmStore.sharedInstance.save(response: response, scenarioName: scenarioName, suite: suite)
    }

    static func delete(responseIndex: Int, scenarioName: String, suite: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(responseIndex: responseIndex, scenarioName: scenarioName, suite: suite)
    }
}

fileprivate struct RealmStore {

    static let sharedInstance = RealmStore()

    var realm: Realm { return try! Realm() }

    func setDefaultRealmForSuite(suiteName: String) {
        var config = Realm.Configuration()
        config.fileURL = FileManager.spooferDocumentsDirectory.appendingPathComponent("\(suiteName).\(realmFileExtension)")
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
}

extension RealmStore: Store {

    // MARK: - Scenario Management

    private func getScenario(_ name: String, suite: String) -> Scenario? {
        setDefaultRealmForSuite(suiteName: suite)
        return realm.objects(Scenario.self).filter("name == %@", name).first
    }

    func allScenarioNames(suite: String) -> [String] {
        setDefaultRealmForSuite(suiteName: suite)
        return realm.objects(Scenario.self).flatMap { $0.name }
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
                // Currently realm does not have a cascade delete mechanism, so delete the sub structures before deleting the scenario
                scenario.apiResponses.forEach({ realm.delete($0.headerFields) })
                realm.delete(scenario.apiResponses)
                // TODO: The above 2 lines can be deleted once cascade delete is implemented in Realm

                realm.delete(scenario)
            }
            return .success(true)
        } catch {
            return .failure(StoreError.unableToDeleteScenario)
        }
    }

    // MARK: - Response Management

    func save(response: APIResponse, scenarioName: String, suite: String) -> Result<APIResponse> {

        guard let scenario = getScenario(scenarioName, suite: suite) else { return .failure(StoreError.scenarioNotFound) }

        do {
            try realm.write {
                scenario.apiResponses.append(response)
            }
            return .success(response)
        } catch {
            return .failure(StoreError.unableToSaveResponse)
        }
    }

    func delete(responseIndex: Int, scenarioName: String, suite: String) -> Result<Bool> {

        guard let scenario = getScenario(scenarioName, suite: suite) else { return .failure(StoreError.scenarioNotFound) }

        do {
            try realm.write {
                scenario.apiResponses.remove(objectAtIndex: responseIndex)
            }
            return .success(true)
        } catch {
            return .failure(StoreError.unableToSaveResponse)
        }
    }
}
