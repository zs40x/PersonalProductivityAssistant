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
    
    init(dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?) {
        self.dataSyncCompletedDelegate = dataSyncCompletedDelegate
    }
    
    public func downloadAndImportTimeLogs() {
        
        let predicate = NSPredicate(value:true)
        let query = CKQuery(recordType: TimeLogsInCK.RecordTypeTimeLogs, predicate: predicate)
        
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (records, error) in
            
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

fileprivate class CkTimeLogRecordImport {
    
    private var ckTimeLog: CKRecord
    private let timeLogRepository = TimeLogRepository()    
    
    init(ckTimeLog: CKRecord) {
        self.ckTimeLog = ckTimeLog
    }    
    
    public func importTimeLog() {
        
        let timeLogData = TimeLogData(ckTimeLog: self.ckTimeLog)
        
        let fetchedTimeLog = timeLogRepository.withUUID(uuid: timeLogData.Uuid).value!
        
        if let timeLog = fetchedTimeLog {
            if fetchedTimeLog!.isEqualTo(timeLogData) {
                NSLog("iCloud download: Skipped already existing, unchanged recored with UUID \(timeLog.uuid)")
                return
            }
            
            fetchedTimeLog!.updateFromTimeLogData(timeLogData)
            
            let saveResult = timeLogRepository.save()
            
            if !saveResult.isSucessful {
                NSLog("Failed to save timeLog changes: \(saveResult.errorMessage)")
                return
            }
            
            NSLog("Updated exiting timeLog from CkRecord: \(timeLogData.Uuid)")
            return;
        }
        
        
        let result = timeLogRepository.addNew(timeLogData)
        
        if !result.isSucessful {
            NSLog("iCloud download: Error persisting timeLog with uuid \(timeLogData.Uuid)")
        } else {
            NSLog("iCloud download: Successfully persisted timeLog with uuid \(timeLogData.Uuid)")
        }
    }
}
