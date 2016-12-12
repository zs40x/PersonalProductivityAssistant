//
//  TimeLogsInCKUpload.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

class TimeLogsInCKUpload {
    
    private var cloudKitContainer: CKContainer
    
    private let timeLogRepository = TimeLogRepository()

    init(cloudKitContainer: CKContainer) {
        self.cloudKitContainer = cloudKitContainer
    }
    
    
    func syncChangesToCloud() {
        
        let getAllTimeLogsResult = timeLogRepository.getAll()
        
        guard getAllTimeLogsResult.isSucessful else {
            return
        }
        
        guard let allTimeLogs = getAllTimeLogsResult.value else {
            return
        }
        
        allTimeLogs.filter({
            $0.cloudSyncPending == NSNumber.init(booleanLiteral: true)
        }).forEach { (timeLog) in
            //saveNewCkRecord(timeLog: timeLog)
        }

    }
    
    private func saveNewCkRecord(timeLog: TimeLog) {
        
        let recordUUID = timeLog.uuid!
        
        
        let ckrTimeLog = CKRecord(recordType: TimeLogsInCK.RecordTypeTimeLogs, recordID: CKRecordID(recordName: recordUUID))
        
        if let activity = timeLog.activity {
            ckrTimeLog.setObject(activity as NSString, forKey: "activity")
            
        }
        
        if let from = timeLog.from {
            ckrTimeLog.setObject(from as NSDate, forKey: "from")
        }
        
        if let until = timeLog.until {
            ckrTimeLog.setObject(until as NSDate, forKey: "until")
        }
        
        
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
