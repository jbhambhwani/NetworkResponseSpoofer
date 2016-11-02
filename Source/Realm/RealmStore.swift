//
//  RealmStore.swift
//  APIResponseSpoofer
//
//  Created by Deepu Mukundan on 11/1/16.
//  Copyright © 2016 Hotwire. All rights reserved.
//

import Foundation

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
    
    func allScenarioNames() -> [String]  {
        return []
    }
    
    func save(scenario: ScenarioV2) -> Result<ScenarioV2> {
        return .success(ScenarioV2())
    }
    
    func load(scenarioName: String) -> Result<ScenarioV2> {
        return .success(ScenarioV2())
    }
    
    func delete(scenarioName: String) -> Result<ScenarioV2> {
        return .success(ScenarioV2())
    }
    
}
