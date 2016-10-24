//
//  TimeLogsInCK.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/10/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

protocol CKDataSyncCompletedDelegate {
    func dataSyncCompleted()
}

class TimeLogsInCK {

    private let timeLogRepository = TimeLogRepository()
    private let cloudKitContainer = CKContainer.default()
    private let recordTypeTimeLogs = "TimeLogs"
    
    var dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?
    
    public func exportTimeLogsToCK() {
        
        let getAllTimeLogsResult = timeLogRepository.getAll()
        
        guard getAllTimeLogsResult.isSucessful else {
            return
        }
        
        guard let allTimeLogs = getAllTimeLogsResult.value else {
            return
        }
        
        for timeLog in allTimeLogs {
            
            let ckrTimeLog = CKRecord(recordType: recordTypeTimeLogs, recordID: CKRecordID(recordName: timeLog.uuid!))
            
            
            if let activity = timeLog.activity {
                ckrTimeLog.setObject(activity as NSString, forKey: "activity")
                
            }
            
            if let from = timeLog.from {
                ckrTimeLog.setObject(from as NSDate, forKey: "from")
            }
            
            if let until = timeLog.until {
                ckrTimeLog.setObject(until as NSDate, forKey: "until")
            }
            
            cloudKitContainer.privateCloudDatabase.save(ckrTimeLog, completionHandler: { (record, error) in
                
                if let error = error {
                    NSLog("Saving to iCloud failed: \(error.localizedDescription)")
                } else {
                    NSLog("Stored record \(record?.recordID)")
                }
                
            })
        }
    }

    public func importTimeLogsFromCkToDb() {
        
        NSLog("TimeLogsInCK.importTimeLogsFromCkToDb()")
        
        let predicate = NSPredicate(value:true)
        let query = CKQuery(recordType: self.recordTypeTimeLogs, predicate: predicate)
        
        cloudKitContainer.privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            if let error = error {
                NSLog("Saving to iCloud failed: \(error.localizedDescription)")
                return
            }
            
            guard let records = records else { return }
            
            NSLog("CK - fetched \(records.count)")
            
            let timeLogRepository = TimeLogRepository()
            
            for ckTimeLog in records {
                
                let activity = ckTimeLog.object(forKey: "activity") as? String ?? ""
                let from = ckTimeLog.object(forKey: "from") as? Date ?? Date()
                let until = ckTimeLog.object(forKey: "until") as? Date ?? Date()
                let uuid = ckTimeLog.object(forKey: "uuid") as? UUID ?? UUID()
                
                let fetchedTimeLog = timeLogRepository.withUUID(uuid: uuid).value!
                
                if let timeLog = fetchedTimeLog {
                    NSLog("Skipped already existing recored with UUID \(timeLog.uuid)")
                    continue
                }
                
                let timeLogData =
                    TimeLogData(UUID: uuid, Activity: activity, From: from, Until: until)
                
                let result = timeLogRepository.addNew(timeLogData)
                
                if !result.isSucessful {
                    NSLog("Error persisting timeLog with uuid \(uuid)")
                } else {
                    NSLog("Successfully persisted timeLog with uuid \(uuid)")
                }
            }
            
            if let delegate = self.dataSyncCompletedDelegate {
                delegate.dataSyncCompleted()
            }
        })
        
    }
}
