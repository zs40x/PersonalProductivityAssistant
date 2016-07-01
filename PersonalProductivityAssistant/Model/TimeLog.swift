//
//  TimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData


class TimeLog: NSManagedObject {

    static let EntityName = "TimeLog"
    
    func durationInMinutes() -> Int {
        guard let timeFrom = from else {
            return 0
        }
        guard let timeUntil = until else {
            return 0
        }
        
        return Int(timeUntil.timeIntervalSinceDate(timeFrom) / 60)
    }
    
    func asTimeLogData() -> TimeLogData {
        return TimeLogData(Activity: activity!, From: from!, Until: until!)
    }
}
