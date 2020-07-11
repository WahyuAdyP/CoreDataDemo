//
//  CoreDataStack.swift
//  CoreDataDemo
//
//  Created by Crocodic-MBP5 on 10/07/20.
//  Copyright © 2020 Crocodic Studio. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    init() {
        // In the init we subscribe to notifications sent by main and background NSManagedObjectContext's on save.
        NotificationCenter.default.addObserver(self,
            selector: #selector(mainContextChanged(notification:)),
            name: .NSManagedObjectContextDidSave,
            object: self.managedObjectContext)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(bgContextChanged(notification:)),
            name: .NSManagedObjectContextDidSave,
            object: self.backgroundManagedObjectContext)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreDataDemo")
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
    }()
    
    // MARK: - iOS 9 and below
    /// Extracted documents directory NSURL getter. NSPersistentStoreCoordinator uses it to create NSPersistentStore at given location.
    lazy var libraryDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    /// Similarly to documents directory, this extracted NSManagedObjectModel getter is used to initialize NSPersistentStoreCoordinator with our model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "CoreDataDemo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// This is where all the wiring up magic is done. First, we create NSPersitentStoreCoordinator with model. Then we retrieve url of our documents directory. Finally we add a persitent store of certain type to NSPersitentStoreCoordinator at documents directory.
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.libraryDirectory.appendingPathComponent("CoreData.sqlite")
        do {
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: url,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ])
            } catch {
                // Report any error we got.
                NSLog("CoreData error \(error), \(String(describing: error._userInfo))")
                fatalError(error.localizedDescription)
            }
        return coordinator
    }()
    
    /// Here we create a 'background' NSManagedObjectContext in a private queue and attach it to our NSPersistentStoreCoordinator. This context is used to perform syncronisation and write operations.
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var privateManagedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateManagedObjectContext.persistentStoreCoordinator = coordinator
        return privateManagedObjectContext
    }()
    
    /// Here we create a 'view' NSManagedObjectContext in a main queue and attach it to our NSPersistentStoreCoordinator. This context is used to fetch data to be displayed on UI.
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    /// This stack uses good old merging contexts triggered on save notifications. In these methods we perform this merging.
    @objc func mainContextChanged(notification: NSNotification) {
        backgroundManagedObjectContext.perform { [unowned self] in
            self.backgroundManagedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
    @objc func bgContextChanged(notification: NSNotification) {
        managedObjectContext.perform{ [unowned self] in
            self.managedObjectContext.mergeChanges(fromContextDidSave: notification as Notification)
        }
    }
}
