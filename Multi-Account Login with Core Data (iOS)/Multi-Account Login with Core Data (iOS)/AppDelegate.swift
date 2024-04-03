//
//  AppDelegate.swift
//  Multi-Account Login with Core Data (iOS)
//
//  Created by SAURABH SHARMA on 26/03/24.
//

import UIKit
import CoreData
import CloudKit

let AppName = "Multi_Account_Login_with_Core_Data__iOS_" // Core Data sqlite filename //

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var semaphore = DispatchSemaphore(value: 1)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AccountViewModel.shared.currentUser = LoginUser(email: UserDefaults.standard.string(forKey: "loggedInUser"))
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    /*lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "Multi_Account_Login_with_Core_Data__iOS_")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()*/

    // MARK: - Core Data Saving support

    /*func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }*/

    var context: NSManagedObjectContext {
        let ctx = self.persistentContainer.get(string: AccountViewModel.shared.currentUser.email!).viewContext
        ctx.shouldDeleteInaccessibleFaults = false
        return ctx
    }
    
    func resetLazyContainer() {
        persistentContainer.clear()
    }
    
    static func storeDescription(for email: String, at url: URL) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: url)
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.cloudKitContainerOptions?.databaseScope = .private
        let settings = UserSettingsHandler(with: email)
        let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.\(Bundle.main.bundleIdentifier!)")
        description.cloudKitContainerOptions = settings.icloudBackupEnabled ? options : nil
        return description
    }
    
    var persistentContainer = LazyContainer<NSPersistentCloudKitContainer> { (email: String) -> NSPersistentCloudKitContainer in
        let container = NSPersistentCloudKitContainer(name: AppName)
        let userSettings = UserSettingsHandler(with: email)
        let iCloudBackupEnabled = userSettings.icloudBackupEnabled
        let storeDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = storeDir.appendingPathComponent("\(email.lowercased())/\(AppName).sqlite")
        let desc = AppDelegate.storeDescription(for: email, at: url)
        container.persistentStoreDescriptions = [desc]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error)
                return
            }
            // Only uncomment the below do-catch block when setting up container first time.//
            /*do {
                try container.initializeCloudKitSchema(options: [])
            } catch {
                print(error)
            }*/
        })
        AppDelegate.semaphore.signal()
        return container
    }
    
    func setupNewContainer(completion: @escaping () ->Void) {
        let storeDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let url = storeDir.appendingPathComponent("\(AccountViewModel.shared.currentUser.email.lowercased())/\(AppName).sqlite")

        self.persistentContainer.get(string: AccountViewModel.shared.currentUser.email.lowercased()).persistentStoreDescriptions = [AppDelegate.storeDescription(for: AccountViewModel.shared.currentUser.email, at: url)]
        let store = self.persistentContainer.get(string: AccountViewModel.shared.currentUser.email.lowercased()).persistentStoreCoordinator.persistentStores.first
        do {
            //try self.persistentContainer.get(string: AccountViewModel.shared.currentUser.email.lowercased()).persistentStoreCoordinator.remove(store!)
            self.persistentContainer.get(string: AccountViewModel.shared.currentUser.email.lowercased()).loadPersistentStores { (desc, err) in
                completion()
            }
        } catch {
            print(error)
            completion()
        }
    }
}

