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
    var Hidden: NSNumber
    var CloudSyncPending: NSNumber
    var CloudSyncStatus: CloudSyncStatus
    
    init(Uuid: UUID, Activity: String, From: Date, Until: Date, Hidden: NSNumber, CloudSyncPending: NSNumber, CloudSyncStatus: CloudSyncStatus) {
        self.Uuid = Uuid
        self.Activity = Activity
        self.From = From
        self.Until = Until
        self.Hidden = Hidden
        self.CloudSyncPending = CloudSyncPending
        self.CloudSyncStatus = CloudSyncStatus
    }
    
    init(Activity: String, From: Date, Until: Date) {
        self.init(
            Uuid: UUID(),
            Activity: Activity,
            From: From,
            Until: Until,
            Hidden: NSNumber.bool_false,
            CloudSyncPending: NSNumber.bool_false,
            CloudSyncStatus: .Unchanged)
    }
    
    init(ckTimeLog: CKRecord) {
        self.init(
            Uuid: UUID.init(uuidString: ckTimeLog.recordID.recordName)!,
            Activity: ckTimeLog.object(forKey: "activity") as! String,
            From: ckTimeLog.object(forKey: "from") as! Date,
            Until: ckTimeLog.object(forKey: "until") as! Date,
            Hidden: ckTimeLog.object(forKey: "hidden") as? NSNumber ?? 0,
            CloudSyncPending: false,
            CloudSyncStatus: .Unchanged)
    }
    
    static func NewRecord(forDate: Date) -> TimeLogData {
        return TimeLogData(
                    Uuid: UUID(),
                    Activity: "",
                    From: forDate,
                    Until: forDate,
                    Hidden: NSNumber.bool_false,
                    CloudSyncPending: true,
                    CloudSyncStatus: .New
                )
    }
}

extension TimeLogData: Equatable {}

func ==(lhs: TimeLogData, rhs: TimeLogData) -> Bool {
    return
           lhs.Uuid == rhs.Uuid
        && lhs.Activity == rhs.Activity
        && lhs.From == rhs.From
        && lhs.Until == rhs.Until
        && lhs.Hidden == rhs.Hidden
        && lhs.CloudSyncStatus == rhs.CloudSyncStatus
        && lhs.CloudSyncPending == rhs.CloudSyncPending
}
