//
//  CoreData.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData

public class CoreData {
    
    let managedObjectModel : NSManagedObjectModel
    let persistentStoreCoordinator : NSPersistentStoreCoordinator
    
    public init(storeType : String, storeURL : NSURL?, schemaName : String, options : [NSObject : AnyObject]?) throws {
        let bundle = NSBundle(forClass:object_getClass(CoreData))
        var modelURL = bundle.URLForResource(schemaName, withExtension: "mom")
        if modelURL == nil {
            modelURL = bundle.URLForResource(schemaName, withExtension: "momd")
        }
        managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)!
        
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        try persistentStoreCoordinator.addPersistentStoreWithType(storeType, configuration: nil, URL: storeURL, options: options)
    }
    
    public convenience init(sqliteDocumentName : String, schemaName : String) throws {
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        let storeURL = CoreData.applicationDocumentsDirectory().URLByAppendingPathComponent(sqliteDocumentName)
        NSLog("%@", storeURL.path!)
        try self.init(storeType: NSSQLiteStoreType, storeURL: storeURL, schemaName: schemaName, options: options)
    }
    
    public convenience init(inMemorySchemaName : String) throws {
        try self.init(storeType: NSInMemoryStoreType, storeURL: nil, schemaName: inMemorySchemaName, options: nil)
    }
    
    private class func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }
    
    public func createManagedObjectContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }
    
}