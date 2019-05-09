//
//  FileManagerExtension.swift
//  NetworkResponseSpoofer
//
//  Created by Deepu Mukundan on 1/19/17.
//  Copyright © 2017 Hotwire. All rights reserved.
//

import Foundation

let realmFileExtension = "realm"

extension FileManager {
    // Retrieve all Realm file names from Spoofer Docs directory
    public class func allSuiteNames() -> [String] {
        var allFiles = [URL]()
        do {
            try allFiles = FileManager.default.contentsOfDirectory(at: spooferDocumentsDirectory,
                                                                   includingPropertiesForKeys: [],
                                                                   options: .skipsSubdirectoryDescendants)
        } catch {
            return []
        }

        let fileNames = allFiles
            .filter { $0.lastPathComponent.hasSuffix(realmFileExtension) }
            .map { $0.deletingPathExtension().lastPathComponent }
        return fileNames.map { String($0) }
    }

    class var spooferDocumentsDirectory: URL {
        let spooferDirectoryURL = applicationDocumentsDirectory.appendingPathComponent("Spoofer")

        var isDir = ObjCBool(true)
        if FileManager.default.fileExists(atPath: spooferDirectoryURL.path, isDirectory: &isDir) == false {
            do {
                try FileManager.default.createDirectory(at: spooferDirectoryURL,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                fatalError("Cannot proceed without Spoofer docs directory access")
            }
        }

        return spooferDirectoryURL
    }

    // MARK: - Private methods

    private class func getSuiteFileURL(_ suiteName: String) -> URL {
        // Get a reference to the documents directory & Construct a file name based on the suite name
        let suiteFileURL = spooferDocumentsDirectory.appendingPathComponent("\(suiteName).\(realmFileExtension)")
        return suiteFileURL
    }

    private class var applicationDocumentsDirectory: URL {
        guard let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Cannot proceed without application docs directory access")
        }
        return docsDir
    }
}
