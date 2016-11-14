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
    func delete(responseIndex: Int, scenarioName: String) -> Result<Bool>
}


enum DataStore {
    
    //
    static func allScenarioNames() -> [String]  {
        return RealmStore.sharedInstance.allScenarioNames()
    }
    
    static func save(scenario: ScenarioV2) -> Result<ScenarioV2> {
        return RealmStore.sharedInstance.save(scenario: scenario)
    }
    
    static func load(scenarioName: String) -> Result<ScenarioV2> {
        return RealmStore.sharedInstance.load(scenarioName: scenarioName)
    }
    
    static func delete(scenarioName: String) -> Result<ScenarioV2> {
        return RealmStore.sharedInstance.delete(scenarioName: scenarioName)
    }

    static func save(response: APIResponseV2, scenarioName: String) -> Result<APIResponseV2> {
        return RealmStore.sharedInstance.save(response: response, scenarioName: scenarioName)
    }

    static func delete(responseIndex: Int, scenarioName: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(responseIndex: responseIndex, scenarioName: scenarioName)
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
    
    // MARK: - Scenario Management
    
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
    
    // MARK: - Response Management
    
    func save(response: APIResponseV2, scenarioName: String) -> Result<APIResponseV2> {
        
        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        
        do {
            try realm.write {
                scenario.apiResponses.append(response)
            }
            return .success(response)
        } catch {
            return .failure(StoreError.unableToSaveResponse)
        }
    }
    
    func delete(responseIndex: Int, scenarioName: String) -> Result<Bool> {

        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        
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
