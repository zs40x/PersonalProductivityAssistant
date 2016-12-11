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
    public static let RecordTypeTimeLogs = "TimeLogs"
    
    var dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?
    
    public func exportTimeLogsToCK() {
        
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
                
                let timeLogRepository = TimeLogRepository()
                
                let getTimeLogResult = timeLogRepository.withUUID(uuid: UUID.init(uuidString: recordUUID)!)
                
                guard getTimeLogResult.isSucessful else {
                    NSLog("Unable to load timeLog \(recordUUID): \(getTimeLogResult.errorMessage)")
                    return
                }
                
                let timeLog = getTimeLogResult.value!!
                
                // remove flag sync pending - assign the UUID
                timeLog.uuid = recordUUID
                timeLog.cloudSyncPending = NSNumber.init(booleanLiteral: false)
                let saveResult = timeLogRepository.save()
                
                if !saveResult.isSucessful {
                    NSLog("Error saving timeLogs to coreData: \(saveResult.errorMessage)")
                }
            }
            
            })
    }

    public func importTimeLogsFromCkToDb() {
        
        NSLog("TimeLogsInCK.importTimeLogsFromCkToDb()")
        
        TimeLogsInCKDownload(
                dataSyncCompletedDelegate: dataSyncCompletedDelegate,
                cloudKitContainer: cloudKitContainer
            ).downloadAndImportTimeLogs()
    }
}
