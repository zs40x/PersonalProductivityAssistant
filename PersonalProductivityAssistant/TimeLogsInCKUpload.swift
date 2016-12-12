//
//  TimeLogsInCKUpload.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

protocol TimeLogCkUpsteamSync {
    
    func syncChanges();
}

class TimeLogsInCKUpload {
    
    private var cloudKitContainer: CKContainer
    
    private let timeLogRepository = TimeLogRepository()

    init(cloudKitContainer: CKContainer) {
        self.cloudKitContainer = cloudKitContainer
    }
    
    
    func syncChangesToCloud() {
        
        let getAllTimeLogsResult = timeLogRepository.getAll()
        
        guard let allTimeLogs = getAllTimeLogsResult.value else {
            return
        }
        
        allTimeLogs.filter({
            $0.cloudSyncPending == NSNumber.init(booleanLiteral: true)
        }).filter({
            $0.cloudSyncStatus == .New
        }).forEach { (timeLog) in
            CkSyncTimeLogNew(
                    timeLog: timeLog,
                    cloudKitContainer: cloudKitContainer
                ).syncChanges()
        }

    }
}

class CkSyncTimeLogNew : TimeLogCkUpsteamSync {
    
    private var timeLog: TimeLog
    private var cloudKitContainer: CKContainer
    
    
    init(timeLog: TimeLog, cloudKitContainer: CKContainer) {
        self.timeLog = timeLog
        self.cloudKitContainer = cloudKitContainer
    }
    
    func syncChanges() {
        
        guard let ckrTimeLog = timeLog.asCKRecord() else {
            NSLog("Abored saveNewCkRecord - probaply due to nil UUID")
            return
        }
        
        let recordUUID = timeLog.uuid!
        
        cloudKitContainer.privateCloudDatabase.save(ckrTimeLog, completionHandler: {
            [recordUUID] (record, error) in
            
            if let error = error {
                NSLog("Saving to iCloud failed: \(error.localizedDescription)")
            } else {
                NSLog("Stored record \(record?.recordID)")
                
                UpdateSyncedTimeLogStatus(ckRecordUUID: recordUUID).saveState()
            }
        })

    }
}

class CkSycNotImplemented : TimeLogCkUpsteamSync {
    
    private var syncStatus: CloudSyncStatus
    
    init(syncStatus: CloudSyncStatus) {
        self.syncStatus = syncStatus
    }
    
    func syncChanges() {
        NSLog("Sync not implemented - syncStatus: \(syncStatus)")
    }
}

class UpdateSyncedTimeLogStatus {
    
    private var ckRecordUUID: String
    
    private let timeLogRepository = TimeLogRepository()
    
    init(ckRecordUUID: String) {
        self.ckRecordUUID = ckRecordUUID
    }
    
    func saveState() {
        
        guard let timeLog = timeLogRecord() else { return }
        
        timeLog.cloudSyncPending = NSNumber.init(booleanLiteral: false)
        timeLog.cloudSyncStatus = .Unchanged
        
        saveTimeLogChanges()
    }
    
    private func timeLogRecord() -> TimeLog? {
        
        let getTimeLogResult = timeLogRepository.withUUID(uuid: UUID.init(uuidString: ckRecordUUID)!)
        
        guard getTimeLogResult.isSucessful else {
            NSLog("Unable to load timeLog \(ckRecordUUID): \(getTimeLogResult.errorMessage)")
            return nil
        }
        
        return getTimeLogResult.value!!
    }
    
    func saveTimeLogChanges() {
        
        let saveResult = timeLogRepository.save()
        
        if !saveResult.isSucessful {
            NSLog("Error saving timeLogs to coreData: \(saveResult.errorMessage)")
        }
    }
}
