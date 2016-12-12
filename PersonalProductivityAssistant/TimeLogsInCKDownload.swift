//
//  TimeLogsInCKDownload.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 11/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

class TimeLogsInCKDownload {
    
    private var dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?
    private var cloudKitContainer: CKContainer
    
    
    init(dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?, cloudKitContainer: CKContainer) {
        self.dataSyncCompletedDelegate = dataSyncCompletedDelegate
        self.cloudKitContainer = cloudKitContainer
    }
    
    public func downloadAndImportTimeLogs() {
        
        let predicate = NSPredicate(value:true)
        let query = CKQuery(recordType: TimeLogsInCK.RecordTypeTimeLogs, predicate: predicate)
        
        cloudKitContainer.privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
            if let error = error {
                NSLog("Downloading from iCloud failed: \(error.localizedDescription)")
                return
            }
            
            guard let records = records else { return }
            
            NSLog("iCloud: fetched \(records.count)")
            
            
            records.forEach({ (ckTimeLog) in
                CkTimeLogRecordImport(ckTimeLog: ckTimeLog).importTimeLog()
            })
            
            if let delegate = self.dataSyncCompletedDelegate {
                delegate.dataSyncCompleted()
            }
        })
    }
    
   
}

class CkTimeLogRecordImport {
    
    private var ckTimeLog: CKRecord
    
    private let timeLogRepository = TimeLogRepository()
    
    
    init(ckTimeLog: CKRecord) {
        self.ckTimeLog = ckTimeLog
    }
    
    
    public func importTimeLog() {
        
        let timeLogData = asTimeLogData()
        
        
        let fetchedTimeLog = timeLogRepository.withUUID(uuid: timeLogData.UUID).value!
        
        if let timeLog = fetchedTimeLog {
            NSLog("iCloud download: Skipped already existing recored with UUID \(timeLog.uuid)")
            return
        }
        
        
        let result = timeLogRepository.addNew(timeLogData)
        
        if !result.isSucessful {
            NSLog("iCloud download: Error persisting timeLog with uuid \(timeLogData.UUID)")
        } else {
            NSLog("iCloud download: Successfully persisted timeLog with uuid \(timeLogData.UUID)")
        }
    }
    
    private func asTimeLogData() -> TimeLogData {
        
        return TimeLogData(
            UUID: UUID.init(uuidString: ckTimeLog.recordID.recordName)!,
            Activity: ckTimeLog.object(forKey: "activity") as! String,
            From: ckTimeLog.object(forKey: "from") as! Date,
            Until: ckTimeLog.object(forKey: "until") as! Date,
            CloudSyncPending: false,
            CloudSyncStatus: .Unchanged
        )
    }
}