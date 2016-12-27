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

public class TimeLogsInCK {

    public static let RecordTypeTimeLogs = "TimeLogs"
    
    var dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?
    
    
    public func exportTimeLogsToCK() {
        
        NSLog("TimeLogsInCK.exportTimeLogsToCK()")
        
        TimeLogsInCKUpload().syncChangesToCloud()
    }

    public func importTimeLogsFromCkToDb() {
        
        NSLog("TimeLogsInCK.importTimeLogsFromCkToDb()")
        
        TimeLogsInCKDownload(
                dataSyncCompletedDelegate: dataSyncCompletedDelegate
            ).downloadAndImportTimeLogs()
    }
    
    public func registerTimeLogChanges() {
        
        NSLog("TimeLogsInCk.registerTimeLogChanges")
        
        TimeLogsInCKSubscription().registerSubscription()
    }
}
