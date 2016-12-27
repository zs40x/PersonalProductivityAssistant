//
//  TimeLogsInCKUpload.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

fileprivate protocol TimeLogCkUpsteamSync {
    
    func syncChanges()
}

fileprivate protocol TimeLogSyncStatusUpdate{
    
    func updateStatusIsSynced()
}


class TimeLogsInCKUpload {
    
    private let timeLogRepository = TimeLogRepository()

    func syncChangesToCloud() {
        
        guard let allTimeLogs = timeLogRepository.getAll().value else { return }
        
        allTimeLogs.filter {
            $0.cloudSyncPending == NSNumber.bool_true
        }.map{
            CkTimeLogSyncFactory( timeLog: $0 ).makeSync( )
        }.forEach{
            $0.syncChanges()
        }
    }
}

fileprivate class CkTimeLogSyncFactory {
    
    private var timeLog: TimeLog
    
    init(timeLog: TimeLog) {
        self.timeLog = timeLog
    }
    
    func makeSync() -> TimeLogCkUpsteamSync {
        
        switch timeLog.cloudSyncStatus {
        case .New:
            return CkSyncTimeLogNew(
                timeLog: timeLog,
                syncStatusUpdate: makeUpdateSyncedTimeLogStatus())
        case .Modified:
            return CkSyncTimeLogModified(
                timeLog: timeLog,
                syncStatusUpdate: makeUpdateSyncedTimeLogStatus())
        case .Deleted:
            return CkSyncTimeLogDelete(
                timeLog: timeLog,
                syncStatusUpdate: makeUpdateSyncedTimeLogStatus())
        default:
            return CkSycNotImplemented(syncStatus:  timeLog.cloudSyncStatus)
        }
    }
    
    private func makeUpdateSyncedTimeLogStatus() -> TimeLogSyncStatusUpdate {
        return UpdateSyncedTimeLogStatus(ckRecordUUID: timeLog.uuid!)
    }
}

fileprivate class AbstractTimeLogsUpstreamSync {
    
    fileprivate var timeLog: TimeLog
    fileprivate var syncStatusUpdate: TimeLogSyncStatusUpdate
    
    fileprivate let timeLogRepository = TimeLogRepository()
    
    init(timeLog: TimeLog, syncStatusUpdate: TimeLogSyncStatusUpdate) {
        self.timeLog = timeLog
        self.syncStatusUpdate = syncStatusUpdate
    }
}

fileprivate class CkSyncTimeLogNew : AbstractTimeLogsUpstreamSync, TimeLogCkUpsteamSync {
    
    func syncChanges() {
        
        guard let ckrTimeLog = timeLog.asCKRecord() else {
            NSLog("Aborted saveNewCkRecord - probably due to nil UUID")
            return
        }
        
        CKContainer.default().privateCloudDatabase.save(ckrTimeLog, completionHandler: {
            (record, error) in
            
            if let error = error {
                NSLog("Saving to iCloud failed: \(error.localizedDescription)")
            } else {
                NSLog("Stored record \(record?.recordID)")
                self.syncStatusUpdate.updateStatusIsSynced()
            }
        })
    }
}

fileprivate class CkSyncTimeLogModified : AbstractTimeLogsUpstreamSync, TimeLogCkUpsteamSync {
    
    func syncChanges() {
        
        let recordUUID = timeLog.uuid!
        
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: CKRecordID.init(recordName: recordUUID), completionHandler: {
            (record, error) in
            
                if let error = error {
                    NSLog("Loading recored to modify from iCloud failed: \(error.localizedDescription)")
                    return
                }
            
                NSLog("Loaded record \(record?.recordID)")
                    
                let modifiedRecored = self.timeLog.modifyCkRecord(ckRecord: record!)
            
                CKContainer.default().privateCloudDatabase.save(modifiedRecored, completionHandler: {
                    (record, error) in
                     
                    if let error = error {
                        NSLog("Update saving to iCloud failed: \(error.localizedDescription)")
                        return
                    }
                    
                    NSLog("Modified record \(record?.recordID)")
                    self.syncStatusUpdate.updateStatusIsSynced()
                })
            })
    }
}

fileprivate class CkSyncTimeLogDelete : AbstractTimeLogsUpstreamSync, TimeLogCkUpsteamSync {
    
    func syncChanges() {
        
        let recordUUID = timeLog.uuid!
        
        CKContainer.default().privateCloudDatabase.delete(withRecordID: CKRecordID.init(recordName: recordUUID), completionHandler: {
            [recordUUID] (record, error) in
            
            if let error = error {
                NSLog("Deleting from iCloud failed: \(error.localizedDescription)")
            } else {
                NSLog("Deleted record \(recordUUID)")
                
                self.syncStatusUpdate.updateStatusIsSynced()
            }
        })
    }
}

fileprivate class CkSycNotImplemented : TimeLogCkUpsteamSync {
    
    private var syncStatus: CloudSyncStatus
    
    init(syncStatus: CloudSyncStatus) {
        self.syncStatus = syncStatus
    }
    
    func syncChanges() {
        NSLog("Sync not implemented - syncStatus: \(syncStatus.rawValue)")
    }
}

fileprivate class UpdateSyncedTimeLogStatus : TimeLogSyncStatusUpdate {
    
    private var ckRecordUUID: String
    
    private let timeLogRepository = TimeLogRepository()
    
    init(ckRecordUUID: String) {
        self.ckRecordUUID = ckRecordUUID
    }
    
    func updateStatusIsSynced() {
        
        guard let timeLog = timeLogRecord() else { return }
        
        timeLog.cloudSyncPending = NSNumber.bool_false
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
    
    private func saveTimeLogChanges() {
        
        let saveResult = timeLogRepository.save()
        
        if !saveResult.isSucessful {
            NSLog("Error saving timeLogs to coreData: \(saveResult.errorMessage)")
        }
    }
}
