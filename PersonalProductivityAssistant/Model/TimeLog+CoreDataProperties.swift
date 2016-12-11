//
//  TimeLog+CoreDataProperties.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 11/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

@objc public enum CloudSyncStatus : Int16
{
    case Unchanged = 1,
         New,
         Modified,
         Deleted
}

extension TimeLog {

    @NSManaged var uuid: String?
    @NSManaged var activity: String?
    @NSManaged var from: Date?
    @NSManaged var until: Date?
    @NSManaged var hashtags: NSSet?
    @NSManaged var cloudSyncPending: NSNumber?
    @NSManaged var cloudSyncStatus: CloudSyncStatus
}
