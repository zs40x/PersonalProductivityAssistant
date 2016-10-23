//
//  TimeLogsInCK.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/10/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

class TimeLogsInCK {

    let timeLogRepository = TimeLogRepository()
    let cloudKitContainer = CKContainer.default()
    
    public func exportTimeLogsToCK() {
        
        let getAllTimeLogsResult = timeLogRepository.getAll()
        
        guard getAllTimeLogsResult.isSucessful else {
            return
        }
        
        guard let allTimeLogs = getAllTimeLogsResult.value else {
            return
        }
        
        for timeLog in allTimeLogs {
            
            let ckrTimeLog = CKRecord(recordType: "TimeLogs", recordID: CKRecordID(recordName: timeLog.uuid!))
            
            
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

}
