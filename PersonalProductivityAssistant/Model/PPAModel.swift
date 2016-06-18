//
//  PPAModel.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

import CoreData

public class PPAModel : NSObject {
    private static let coreData = try! CoreData(sqliteDocumentName: "PPA.db", schemaName:"PPADataModel")
    
    public static func New() -> PPAModel {
        return PPAModel(managedObjectContext:coreData.createManagedObjectContext())
    }
    
    
    private let managedObjectContext : NSManagedObjectContext
    
    init(managedObjectContext : NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        super.init()
    }
    
    var timeLogs : [TimeLog] {
        let request = NSFetchRequest(entityName: TimeLog.EntityName)
        request.sortDescriptors = [NSSortDescriptor(key: "activity", ascending: true)]
        return try! managedObjectContext.executeFetchRequest(request) as! [TimeLog]
    }
    
    func createTimeLog(activityName: String) -> TimeLog {
        let timeLog =
            NSEntityDescription.insertNewObjectForEntityForName(
                TimeLog.EntityName, inManagedObjectContext: self.managedObjectContext) as! TimeLog
        
        timeLog.activity = activityName
        
        return timeLog
    }
    
    func save() {
        do {
            try self.managedObjectContext.save()
        }
        catch let error as NSError {
            NSLog("Error saving: %@", error)
        }
    }
    
}
