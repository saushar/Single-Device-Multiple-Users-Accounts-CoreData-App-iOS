//
//  RealmViewModel.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 18/06/20.
//  Copyright © 2020 SAURABH SHARMA. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LocalDatabaseManager {
    
    class func reset(completion: @escaping ((Bool) -> Void)) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let email = AccountViewModel.shared.currentUser.email!
        let pc = app.persistentContainer.get(string: email)
        do {
            let coordinator = pc.persistentStoreCoordinator
            guard let url = coordinator.persistentStores.first?.url else {
                completion(false)
                return
            }
            try coordinator.remove(coordinator.persistentStores.first!)
            app.resetLazyContainer()
            let fileUrls = try FileManager.default.contentsOfDirectory(at: url.deletingLastPathComponent(), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileUrl in fileUrls {
                try FileManager.default.removeItem(at: fileUrl)
            }
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: "Default", at: url, options: nil)
            completion(true)
        } catch {
            completion(false)
            print(error)
        }
    }
    
    class func backup(completion: @escaping ((Bool) -> Void)) {
        let appSupportUrl: URL = FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask)[0]
        let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let timestamp = Int(Date().timeIntervalSinceReferenceDate)
        let app = UIApplication.shared.delegate as! AppDelegate
        let email = AccountViewModel.shared.currentUser.email!
        let url = doc.appendPathComponent(with: "\(email)/\(AppName)-\(timestamp).sqlite")
        let destURL = appSupportUrl.appendingPathComponent(email + "/" + "\(AppName).sqlite")
        
        let currPC = app.persistentContainer.get(string: email)
        let currPSC = currPC.persistentStoreCoordinator
        let currDesc = currPC.persistentStoreDescriptions.first
        currDesc?.shouldMigrateStoreAutomatically = true
        currDesc?.shouldInferMappingModelAutomatically = true
        
        let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
        DispatchQueue.global().async {
            do {
                if !FileManager.default.fileExists(atPath: url.deletingLastPathComponent().path) {
                    try FileManager.default.createDirectory(at: doc.appendPathComponent(with: email), withIntermediateDirectories: true, attributes: [:])
                }
                let newStore = try currPSC.migratePersistentStore(currPSC.persistentStores.first!, to: url, options: currPC.persistentStoreDescriptions.last?.options, withType: NSSQLiteStoreType)
                
                try currPSC.destroyPersistentStore(at: destURL, ofType: NSSQLiteStoreType, options: options)
                
                let _ = try currPSC.migratePersistentStore(newStore, to: destURL, options: options, withType: NSSQLiteStoreType)
                            
                completion(true)
            } catch {
                completion(false)
                print("Failed to migrate with \(error)")
            }
        }        
    }
    
    class func restoreFromStore(url: URL, completion: @escaping ((Bool) -> Void)) {
        let appSupportUrl: URL = FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask)[0]
        let app = UIApplication.shared.delegate as! AppDelegate
        let email = AccountViewModel.shared.currentUser.email!
        let destURL = appSupportUrl.appendingPathComponent(email + "/" + "\(AppName).sqlite")
        let currPC = app.persistentContainer.get(string: email)
        let currPSC = currPC.persistentStoreCoordinator
        let options = currPC.persistentStoreDescriptions.first?.options
        let configuration = currPC.persistentStoreDescriptions.first?.configuration
        DispatchQueue.global().async {
            do {
                if !FileManager.default.fileExists(atPath: destURL.deletingLastPathComponent().path) {
                    try FileManager.default.createDirectory(at: appSupportUrl.appendPathComponent(with: email), withIntermediateDirectories: true, attributes: [:])
                }
                let _ = try currPSC.destroyPersistentStore(at: destURL, ofType: NSSQLiteStoreType, options: options)
                
                let newStore = try currPSC.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: configuration, at: url, options: options)
                
                let _ = try currPSC.migratePersistentStore(newStore, to: destURL, options: options, withType: NSSQLiteStoreType)
                
                completion(true)
            } catch {
                completion(false)
                print("Failed to migrate with \(error)")
            }
        }
    }    
}

extension URL {
    static let appSupportUrl: URL? = FileManager.default.urls(for: .applicationSupportDirectory, in:.userDomainMask).first
    static let docDirectoryUrl: URL? = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first
    func appendPathComponent(with pathComponent: String) -> URL {
        return self.appendingPathComponent(pathComponent)
    }
    var fileExists: Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
    func removeItem() throws {
        try FileManager.default.removeItem(at: self)
    }
}
