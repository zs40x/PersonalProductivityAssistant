//
//  XCTestCaseCoreDataInMemory.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 10/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
import CoreData

class XCTestCaseCoreDataInMemory: XCTestCase {

    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
 
    override func setUp() {
        managedObjectModel = NSManagedObjectModel.mergedModel(from: nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            store =
                try storeCoordinator.addPersistentStore(
                    ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        }
        catch let error as NSError {
            XCTFail("could't initialize core data inMemory store \(error)")
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        super.setUp()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        
        do {
            try storeCoordinator.remove(store)
        }
        catch let error as NSError {
            XCTFail("couldn't remove core data inMemory store: \(error)")
        }
        
        super.tearDown()
    }
}
