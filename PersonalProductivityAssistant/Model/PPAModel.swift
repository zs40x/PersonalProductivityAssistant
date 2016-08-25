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

public class PPAModel : NSObject {
    
    public static func New() -> PPAModel {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        return PPAModel(managedObjectContext:appDelegate.managedObjectContext)
    }
    
    
    var managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
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
    
    private let managedObjectContext : NSManagedObjectContext
    
    private init(managedObjectContext : NSManagedObjectContext) {
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
        
        request.predicate = NSPredicate(format: "((from >= %@) AND (from < %@)) || (from = nil)", dateFrom, dateUntil)
        
        request.sortDescriptors = [NSSortDescriptor(key: "from", ascending: true)]
        
        do {
            return try managedObjectContext.fetch(request)
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
        
        timeLog.activity = timeLogData.Activity
        timeLog.from = timeLogData.From
        timeLog.until = timeLogData.Until
        
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
