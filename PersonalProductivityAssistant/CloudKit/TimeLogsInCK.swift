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
            
            let ckrTimeLog = CKRecord(recordType: "TimeLog", recordID: CKRecordID(recordName: timeLog.uuid!))
            
            
            
            
        }
    }

}
