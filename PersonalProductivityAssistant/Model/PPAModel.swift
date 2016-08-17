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
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
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
        let request = NSFetchRequest(entityName: TimeLog.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "activity", ascending: true)]
        
        do {
            return try managedObjectContext.executeFetchRequest(request) as! [TimeLog]
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func getTimeLogsForDateRange(dateFrom: NSDate, dateUntil: NSDate) throws -> [TimeLog] {
        let request = NSFetchRequest(entityName: TimeLog.EntityName)
        request.predicate = NSPredicate(format: "((from >= %@) AND (from < %@)) || (from = nil)", dateFrom, dateUntil)
        
        do {
            return try managedObjectContext.executeFetchRequest(request) as! [TimeLog]
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func createTimeLog(timeLogData: TimeLogData) -> TimeLog {
        let timeLog =
            NSEntityDescription.insertNewObjectForEntityForName(
                TimeLog.EntityName, inManagedObjectContext: self.managedObjectContext) as! TimeLog
        
        timeLog.activity = timeLogData.Activity
        timeLog.from = timeLogData.From
        timeLog.until = timeLogData.Until
        
        return timeLog
    }
    
    func deleteTimeLog(timeLogToDelete: TimeLog) {
        managedObjectContext.deleteObject(timeLogToDelete)
    }
}

internal class HashtagModel : AbstractModel {
    
    func getAllHashtags() throws -> [Hashtag] {
        let request = NSFetchRequest(entityName: Hashtag.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let result = try managedObjectContext.executeFetchRequest(request) as! [Hashtag]
            return result
        }
        catch let error as NSError {
            NSLog("Error fetching: %@", error)
            throw error
        }
    }
    
    func createHashtag(withName name: String) -> Hashtag {
        let hashTag =
            NSEntityDescription.insertNewObjectForEntityForName(Hashtag.EntityName, inManagedObjectContext: self.managedObjectContext) as! Hashtag
        
        hashTag.name = name
        
        return hashTag
    }
}
