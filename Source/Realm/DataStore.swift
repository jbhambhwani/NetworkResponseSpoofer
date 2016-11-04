//
//  DataStore.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

enum DataStoreError: Error {
    case notFound
    case unableToSave
    case unableToDelete
}

protocol Store {
    func allScenarioNames() -> [String]
    func save(scenario: ScenarioV2) -> Result<ScenarioV2>
    func load(scenarioName: String) -> Result<ScenarioV2>
    func delete(scenarioName: String) -> Result<ScenarioV2>
}


enum DataStore {
    
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
    
}


fileprivate struct RealmStore: Store {

    static let sharedInstance = RealmStore()
    
    init() {
        print("DataStore Path: \(realm.configuration.fileURL)")
    }
    
    func allScenarioNames() -> [String]  {
        let allScenarios = realm.objects(ScenarioV2.self)
        return allScenarios.flatMap { $0.name }
    }
    
    func save(scenario: ScenarioV2) -> Result<ScenarioV2> {
        do {
            try realm.write {
                realm.add(scenario, update: true)
            }
            return .success(scenario)
        } catch {
            return .failure(DataStoreError.unableToSave)
        }
    }
    
    func load(scenarioName: String) -> Result<ScenarioV2> {
        let allScenarios = realm.objects(ScenarioV2.self)
        guard let scenario = allScenarios.filter("name == %@",scenarioName).first else {
            return .failure(DataStoreError.notFound)
        }
        return .success(scenario)
    }
    
    func delete(scenarioName: String) -> Result<ScenarioV2> {
        let allScenarios = realm.objects(ScenarioV2.self)
        let scenario = allScenarios.filter("name == %@",scenarioName).first
        guard let scenarioToDelete = scenario else { return .failure(DataStoreError.notFound) }
        do {
            try realm.write {
                realm.delete(scenarioToDelete)
            }
            return .success(scenarioToDelete)
        } catch {
            return .failure(DataStoreError.unableToDelete)
        }
    }
    
    let realm = try! Realm()
}
