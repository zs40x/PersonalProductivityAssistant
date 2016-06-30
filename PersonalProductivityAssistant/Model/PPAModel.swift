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
    
    
    private let managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
    }
    
    func getAllTimeLogs() throws -> [TimeLog] {
        let request = NSFetchRequest(entityName: TimeLog.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "activity", ascending: true)]
        
        do {
            let result = try managedObjectContext.executeFetchRequest(request) as! [TimeLog]
            return result
        }
        catch let error as NSError {
            NSLog("Error saving: %@", error)
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
    
    func save() throws {
        do {
            try self.managedObjectContext.save()
        } catch let error as NSError {
            NSLog("Error saving: %@", error)
            throw error
        }
    }
    
}
