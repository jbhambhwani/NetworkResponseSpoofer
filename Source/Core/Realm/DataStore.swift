//
//  DataStore.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

enum StoreError: Error {
    case scenarioNotFound
    case unableToSaveScenario
    case unableToSaveResponse
    case unableToDeleteScenario
}

protocol Store {
    // Scenario
    func allScenarioNames() -> [String]
    func save(scenario: ScenarioV2) -> Result<ScenarioV2>
    func load(scenarioName: String) -> Result<ScenarioV2>
    func delete(scenarioName: String) -> Result<ScenarioV2>
    // Response
    func save(response: APIResponseV2, scenarioName: String) -> Result<APIResponseV2>
}


enum DataStore {
    
    static func allScenarioNames() -> [String]  {
        return RealmStore.sharedInstance.allScenarioNames()
    }
    
    static func save(scenario: ScenarioV2) -> Result<ScenarioV2> {
        return RealmStore.sharedInstance.save(scenario: scenario)
    }

    // TODO: Does not need to be discardable
    @discardableResult static func save(response: APIResponseV2, scenarioName: String) -> Result<APIResponseV2> {
        return RealmStore.sharedInstance.save(response: response, scenarioName: scenarioName)
    }
    
    static func load(scenarioName: String) -> Result<ScenarioV2> {
        return RealmStore.sharedInstance.load(scenarioName: scenarioName)
    }
    
    static func delete(scenarioName: String) -> Result<ScenarioV2> {
        return RealmStore.sharedInstance.delete(scenarioName: scenarioName)
    }
    
}


fileprivate struct RealmStore {

    static let sharedInstance = RealmStore()
    var realm: Realm { return try! Realm() }
    
    init() {
        print("\nDataStore Path: \(Realm.Configuration.defaultConfiguration.fileURL)\n")
    }
}

extension RealmStore: Store {
    
    private func getScenario(_ name: String) -> ScenarioV2? {
        return realm.objects(ScenarioV2.self).filter("name == %@", name).first
    }
    
    func allScenarioNames() -> [String]  {
        return realm.objects(ScenarioV2.self).flatMap { $0.name }
    }
    
    func save(scenario: ScenarioV2) -> Result<ScenarioV2> {
        do {
            try realm.write {
                realm.add(scenario, update: true)
            }
            return .success(scenario)
        } catch {
            return .failure(StoreError.unableToSaveScenario)
        }
    }
    
    // Rename - since this is not loading to memory
    func load(scenarioName: String) -> Result<ScenarioV2> {
        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        return .success(scenario)
    }
    
    func delete(scenarioName: String) -> Result<ScenarioV2> {
        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        
        do {
            try realm.write {
                realm.delete(scenario)
            }
            return .success(scenario)
        } catch {
            return .failure(StoreError.unableToDeleteScenario)
        }
    }
    
    func save(response: APIResponseV2, scenarioName: String) -> Result<APIResponseV2> {
        
        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        scenario.apiResponses.append(response)
        
        do {
            try realm.write {
                realm.add(scenario, update: true)
            }
            return .success(response)
        } catch {
            return .failure(StoreError.unableToSaveResponse)
        }
    }
    
}
