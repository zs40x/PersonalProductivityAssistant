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
import CloudKit

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
            Uuid: UUID(uuidString: uuid!)!,
            Activity: activity!,
            From: from!,
            Until: until!,
            CloudSyncPending: cloudSyncPending!,
            CloudSyncStatus: cloudSyncStatus)
    }
    
    func asCKRecord() -> CKRecord? {
    
        guard let recordUUID = uuid else { return nil }
    
        let ckrTimeLog =
            CKRecord(
                recordType: TimeLogsInCK.RecordTypeTimeLogs,
                recordID: CKRecordID(recordName: recordUUID)
            )
    
        if let activity = activity {
            ckrTimeLog.setObject(activity as NSString, forKey: "activity")
        }
    
        if let from = from {
            ckrTimeLog.setObject(from as NSDate, forKey: "from")
        }
    
        if let until = until {
            ckrTimeLog.setObject(until as NSDate, forKey: "until")
        }
        
        return ckrTimeLog
    }
    
    func modifyCkRecord(ckRecord: CKRecord) -> CKRecord {
        
        let modifiedRecord = ckRecord
        
        if let activity = self.activity {
            modifiedRecord.setObject(activity as NSString, forKey: "activity")
        }
        
        if let from = self.from {
            modifiedRecord.setObject(from as NSDate, forKey: "from")
        }
        
        if let until = self.until {
            modifiedRecord.setObject(until as NSDate, forKey: "until")
        }
        
        return modifiedRecord
    }
    
    func updateFromTimeLogData(_ timeLogData: TimeLogData) {
        self.activity = timeLogData.Activity
        self.from = timeLogData.From
        self.until = timeLogData.Until
        self.uuid = timeLogData.Uuid.uuidString
        self.cloudSyncPending = timeLogData.CloudSyncPending
        self.cloudSyncStatus = timeLogData.CloudSyncStatus
        
        self.updateHashtags()
    }
    
    func updateHashtags() {
        let foundHashtags =
            HashtagFinder(hashtagRepository: HashtagRepository())
                .resolveHashtags(stringWithHastags: self.activity!).value!
        
        self.hashtags = NSSet(array: foundHashtags)
    }
}
