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
            
            NSLog("CK - fetched \(records.count)")
            
            let timeLogRepository = TimeLogRepository()
            
            for ckTimeLog in records {
                
                let activity = ckTimeLog.object(forKey: "activity") as? String ?? ""
                let from = ckTimeLog.object(forKey: "from") as? Date ?? Date()
                let until = ckTimeLog.object(forKey: "until") as? Date ?? Date()
                let uuid = UUID.init(uuidString: ckTimeLog.recordID.recordName)!
                
                let fetchedTimeLog = timeLogRepository.withUUID(uuid: uuid).value!
                
                if let timeLog = fetchedTimeLog {
                    NSLog("Skipped already existing recored with UUID \(timeLog.uuid)")
                    continue
                }
                
                let timeLogData =
                    TimeLogData(
                        UUID: uuid,
                        Activity: activity,
                        From: from,
                        Until: until,
                        CloudSyncPending: false,
                        CloudSyncStatus: .Unchanged
                )
                
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
