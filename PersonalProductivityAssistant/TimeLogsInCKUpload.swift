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
    
    func syncChanges()
}

protocol TimeLogSyncStatusUpdate{
    
    func updateStatusIsSynced()
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
        }).forEach { (timeLog) in
            
            CkTimeLogSyncFactory(
                    cloudKitContainer: cloudKitContainer,
                    timeLog: timeLog
                ).makeSync(
                ).syncChanges()
        }
    }
}

class AbstractTimeLogsUpstreamSync {
    
    fileprivate var syncStatusUpdate: TimeLogSyncStatusUpdate
    fileprivate var cloudKitContainer: CKContainer
    
    fileprivate let timeLogRepository = TimeLogRepository()
    
    init(cloudKitContainer: CKContainer, syncStatusUpdate: TimeLogSyncStatusUpdate) {
        self.cloudKitContainer = cloudKitContainer
        self.syncStatusUpdate = syncStatusUpdate
    }
}

class CkSyncTimeLogNew : AbstractTimeLogsUpstreamSync {
    
    private var timeLog: TimeLog
    
    init(timeLog: TimeLog, cloudKitContainer: CKContainer, syncStatusUpdate: TimeLogSyncStatusUpdate) {
        
        self.cloudKitContainer = cloudKitContainer
        self.syncStatusUpdate = syncStatusUpdate
        self.timeLog = timeLog
    }
    
    func syncChanges() {
        
        guard let ckrTimeLog = timeLog.asCKRecord() else {
            NSLog("Abored saveNewCkRecord - probaply due to nil UUID")
            return
        }
        
        cloudKitContainer.privateCloudDatabase.save(ckrTimeLog, completionHandler: {
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

class CkSyncTimeLogModified : TimeLogCkUpsteamSync {
    
    private var timeLog: TimeLog
    private var cloudKitContainer: CKContainer
    
    init(timeLog: TimeLog, cloudKitContainer: CKContainer) {
        self.timeLog = timeLog
        self.cloudKitContainer = cloudKitContainer
    }
    
    func syncChanges() {
        
        let recordUUID = timeLog.uuid!
        
        cloudKitContainer.privateCloudDatabase.fetch(withRecordID: CKRecordID.init(recordName: recordUUID), completionHandler: {
            (record, error) in
            
                if let error = error {
                    NSLog("Loading recored to modify from iCloud failed: \(error.localizedDescription)")
                } else {
                    NSLog("Loaded record \(record?.recordID)")
                    
                    let modifiedRecored = record!
                    
                    if let activity = self.timeLog.activity {
                        modifiedRecored.setObject(activity as NSString, forKey: "activity")
                    }
                    
                    if let from = self.timeLog.from {
                        modifiedRecored.setObject(from as NSDate, forKey: "from")
                    }
                    
                    if let until = self.timeLog.until {
                        modifiedRecored.setObject(until as NSDate, forKey: "until")
                    }
                    
                    self.cloudKitContainer.privateCloudDatabase.save(modifiedRecored, completionHandler: {
                        [recordUUID] (record, error) in
                     
                        if let error = error {
                            NSLog("Update saving to iCloud failed: \(error.localizedDescription)")
                        } else {
                            NSLog("Modified record \(record?.recordID)")
                     
                            UpdateSyncedTimeLogStatus(ckRecordUUID: recordUUID).saveState()
                        }
                     })
                }
            })
    }

}

class CkSyncTimeLogDelete : TimeLogCkUpsteamSync {
    
    private var timeLog: TimeLog
    private var cloudKitContainer: CKContainer
    
    
    init(timeLog: TimeLog, cloudKitContainer: CKContainer) {
        self.timeLog = timeLog
        self.cloudKitContainer = cloudKitContainer
    }
    
    func syncChanges() {
        
        let recordUUID = timeLog.uuid!
        
        cloudKitContainer.privateCloudDatabase.delete(withRecordID: CKRecordID.init(recordName: recordUUID), completionHandler: {
            [recordUUID] (record, error) in
            
            if let error = error {
                NSLog("Deleting from iCloud failed: \(error.localizedDescription)")
            } else {
                NSLog("Deleted record \(recordUUID)")
                
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
        NSLog("Sync not implemented - syncStatus: \(syncStatus.rawValue)")
    }
}

class CkTimeLogSyncFactory {
    
    private var cloudKitContainer: CKContainer
    private var timeLog: TimeLog
    
    init(cloudKitContainer: CKContainer, timeLog: TimeLog) {
        self.cloudKitContainer = cloudKitContainer
        self.timeLog = timeLog
    }
    
    func makeSync() -> TimeLogCkUpsteamSync {
        
        switch timeLog.cloudSyncStatus {
        case .New:
            return CkSyncTimeLogNew(timeLog: timeLog, cloudKitContainer: cloudKitContainer, syncStatusUpdate: UpdateSyncedTimeLogStatus(ckRecordUUID: timeLog.uuid!)) as! TimeLogCkUpsteamSync
        case .Modified:
            return CkSyncTimeLogModified(timeLog: timeLog, cloudKitContainer: cloudKitContainer)
        case .Deleted:
            return CkSyncTimeLogDelete(timeLog: timeLog, cloudKitContainer: cloudKitContainer)
        default:
            return CkSycNotImplemented(syncStatus:  timeLog.cloudSyncStatus)
        }
    }
}

class UpdateSyncedTimeLogStatus : TimeLogSyncStatusUpdate {
    
    private var ckRecordUUID: String
    
    private let timeLogRepository = TimeLogRepository()
    
    init(ckRecordUUID: String) {
        self.ckRecordUUID = ckRecordUUID
    }
    
    
    func updateStatusIsSynced() {
        
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
    
    private func saveTimeLogChanges() {
        
        let saveResult = timeLogRepository.save()
        
        if !saveResult.isSucessful {
            NSLog("Error saving timeLogs to coreData: \(saveResult.errorMessage)")
        }
    }
}
