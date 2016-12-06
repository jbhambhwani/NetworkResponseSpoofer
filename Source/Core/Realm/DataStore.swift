//
//  DataStore.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation
import RealmSwift

public enum StoreError: Int, Error {
    case scenarioNotFound
    case unableToSaveScenario
    case unableToSaveResponse
    case unableToDeleteScenario
}

protocol Store {
    // Scenario
    func allScenarioNames() -> [String]
    func save(scenario: Scenario) -> Result<Scenario>
    func load(scenarioName: String) -> Result<Scenario>
    func delete(scenarioName: String) -> Result<Bool>
    // Response
    func save(response: APIResponse, scenarioName: String) -> Result<APIResponse>
    func delete(responseIndex: Int, scenarioName: String) -> Result<Bool>
}


enum DataStore {
    
    //
    static func allScenarioNames() -> [String]  {
        return RealmStore.sharedInstance.allScenarioNames()
    }
    
    static func save(scenario: Scenario) -> Result<Scenario> {
        return RealmStore.sharedInstance.save(scenario: scenario)
    }
    
    static func load(scenarioName: String) -> Result<Scenario> {
        return RealmStore.sharedInstance.load(scenarioName: scenarioName)
    }
    
    static func delete(scenarioName: String) -> Result<Bool> {
        return RealmStore.sharedInstance.delete(scenarioName: scenarioName)
    }

    static func save(response: APIResponse, scenarioName: String) -> Result<APIResponse> {
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
    
    private func getScenario(_ name: String) -> Scenario? {
        return realm.objects(Scenario.self).filter("name == %@", name).first
    }
    
    func allScenarioNames() -> [String]  {
        return realm.objects(Scenario.self).flatMap { $0.name }
    }
    
    func save(scenario: Scenario) -> Result<Scenario> {
        do {
            try realm.write {
                realm.add(scenario, update: true)
            }
            return .success(scenario)
        } catch {
            return .failure(StoreError.unableToSaveScenario)
        }
    }
    
    func load(scenarioName: String) -> Result<Scenario> {
        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        return .success(scenario)
    }
    
    func delete(scenarioName: String) -> Result<Bool> {
        guard let scenario = getScenario(scenarioName) else { return .failure(StoreError.scenarioNotFound) }
        
        do {
            try realm.write {
                // Currently realm does not have a cascade delete mechanism, so delete the sub structures before deleting the scenario
                scenario.apiResponses.forEach( { realm.delete($0.headerFields) })
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
    
    func save(response: APIResponse, scenarioName: String) -> Result<APIResponse> {
        
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
