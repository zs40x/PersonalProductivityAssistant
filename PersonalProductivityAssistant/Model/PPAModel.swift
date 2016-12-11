//
//  PPAModel.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit
import CoreData

open class PPAModel : NSObject {
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("PPA.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var applicationDocumentsDirectory: URL = {
        
        let fileManager = FileManager.default
        
        if let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.de.sme.ppa") {
            return url
        }
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "PPADataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    private static var singletonInstance = PPAModel()
    
    private override init() { }
    
    public static func sharedInstance() -> PPAModel {
        return singletonInstance
    }
    
    
    var TimeLogs: TimeLogModel {
        get {
            return TimeLogModel(managedObjectContext: managedObjectContext)
        }
    }
    
    var Hashtags: HashtagModel {
        get {
            return HashtagModel(managedObjectContext: managedObjectContext)
        }
    }
    
    func save() throws {
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            NSLog("Error saving: %@", error)
            throw error
        }
    }
}


internal class AbstractModel {
    
    fileprivate let managedObjectContext : NSManagedObjectContext
    
    fileprivate init(managedObjectContext : NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }
    
}

internal class TimeLogModel : AbstractModel {
    
    func getAllTimeLogs() throws -> [TimeLog] {
        
        let request = NSFetchRequest<TimeLog>(entityName: TimeLog.EntityName)
        
        request.sortDescriptors = [NSSortDescriptor(key: "from", ascending: true)]
        
        do {
            return try managedObjectContext.fetch(request)
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func getTimeLogsForDateRange(_ dateFrom: Date, dateUntil: Date) throws -> [TimeLog] {
        
        let request = NSFetchRequest<TimeLog>(entityName: TimeLog.EntityName)
        
        request.predicate = NSPredicate(format: "((from >= %@) AND (from < %@)) || (from = nil)", dateFrom as CVarArg, dateUntil as CVarArg)
        
        request.sortDescriptors = [NSSortDescriptor(key: "from", ascending: true)]
        
        do {
            return try managedObjectContext.fetch(request)
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func getTimeLogByUuid(uuid: UUID) throws -> TimeLog? {
        
        let request = NSFetchRequest<TimeLog>(entityName: TimeLog.EntityName)
        
        request.predicate = NSPredicate(format: "uuid = %@", uuid as CVarArg)
        
        do {
            return try managedObjectContext.fetch(request).first
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func createTimeLog(_ timeLogData: TimeLogData) -> TimeLog {
        
        let timeLog =
            NSEntityDescription.insertNewObject(
                forEntityName: TimeLog.EntityName, into: self.managedObjectContext) as! TimeLog
        
        timeLog.uuid = timeLogData.UUID.uuidString
        timeLog.activity = timeLogData.Activity
        timeLog.from = timeLogData.From
        timeLog.until = timeLogData.Until
        timeLog.cloudSyncPending = timeLogData.CloudSyncPending
        timeLog.cloudSyncStatus = timeLogData.CloudSyncStatus
        
        return timeLog
    }
    
    func deleteTimeLog(_ timeLogToDelete: TimeLog) {
        managedObjectContext.delete(timeLogToDelete)
    }
}

internal class HashtagModel : AbstractModel {
    
    func getAllHashtags() throws -> [Hashtag] {
        let request = NSFetchRequest<Hashtag>(entityName: Hashtag.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let result = try managedObjectContext.fetch(request)
            return result
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func createHashtag(withName name: String) -> Hashtag {
        let hashTag =
            NSEntityDescription.insertNewObject(forEntityName: Hashtag.EntityName, into: self.managedObjectContext) as! Hashtag
        
        hashTag.name = name
        
        return hashTag
    }
}
