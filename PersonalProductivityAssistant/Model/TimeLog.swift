//
//  TimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TimeLog: NSManagedObject {

    static let EntityName = "TimeLog"
    
    func durationInMinutes() -> Int {
        guard let timeFrom = from else {
            return 0
        }
        guard let timeUntil = until else {
            return 0
        }
        
        return Int(timeUntil.timeIntervalSince(timeFrom as Date) / 60)
    }
    
    func asTimeLogData() -> TimeLogData {
        return TimeLogData(
            UUID: UUID(uuidString: uuid!)!,
            Activity: activity!,
            From: from!,
            Until: until!,
            CloudSyncPending: cloudSyncPending!,
            CloudSyncStatus: cloudSyncStatus)
    }
    
    func updateFromTimeLogData(_ timeLogData: TimeLogData) {
        self.activity = timeLogData.Activity
        self.from = timeLogData.From
        self.until = timeLogData.Until
        self.uuid = timeLogData.UUID.uuidString
        self.cloudSyncPending = NSNumber.init(booleanLiteral: true)
        
        self.updateHashtags()
    }
    
    func updateHashtags() {
        let foundHashtags =
            HashtagFinder(hashtagRepository: HashtagRepository())
                .resolveHashtags(stringWithHastags: self.activity!).value!
        
        self.hashtags = NSSet(array: foundHashtags)
    }
}
