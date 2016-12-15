//
//  TimeLogData.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 23/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

struct TimeLogData {
    var Uuid: UUID
    var Activity: String
    var From: Date
    var Until: Date
    var CloudSyncPending: NSNumber
    var CloudSyncStatus: CloudSyncStatus
    
    init(Uuid: UUID, Activity: String, From: Date, Until: Date, CloudSyncPending: NSNumber, CloudSyncStatus: CloudSyncStatus) {
        self.Uuid = Uuid
        self.Activity = Activity
        self.From = From
        self.Until = Until
        self.CloudSyncPending = CloudSyncPending
        self.CloudSyncStatus = CloudSyncStatus
    }
    
    init(ckTimeLog: CKRecord) {
        self.init(
            Uuid: UUID.init(uuidString: ckTimeLog.recordID.recordName)!,
            Activity: ckTimeLog.object(forKey: "activity") as! String,
            From: ckTimeLog.object(forKey: "from") as! Date,
            Until: ckTimeLog.object(forKey: "until") as! Date,
            CloudSyncPending: false,
            CloudSyncStatus: .Unchanged)
    }
}
