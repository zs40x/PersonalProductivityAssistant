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

extension TimeLog {

    @NSManaged var activity: String?
    @NSManaged var from: NSDate?
    @NSManaged var until: NSDate?
    @NSManaged var hashtags: NSSet?

}
