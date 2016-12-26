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

    private let timeLogRepository = TimeLogRepository()
    private let cloudKitContainer = CKContainer.default()
    public static let RecordTypeTimeLogs = "TimeLogs"
    
    var dataSyncCompletedDelegate: CKDataSyncCompletedDelegate?
    
    
    public func exportTimeLogsToCK() {
        
        NSLog("exportTimeLogsToCK()")
        
        TimeLogsInCKUpload(
            cloudKitContainer: cloudKitContainer
            ).syncChangesToCloud()
    }

    public func importTimeLogsFromCkToDb() {
        
        NSLog("TimeLogsInCK.importTimeLogsFromCkToDb()")
        
        TimeLogsInCKDownload(
                dataSyncCompletedDelegate: dataSyncCompletedDelegate,
                cloudKitContainer: cloudKitContainer
            ).downloadAndImportTimeLogs()
    }
    
    public func registerTimeLogChanges() {
        
        NSLog("TimeLogsInCk.registerTimeLogChanges")
        
        TimeLogsInCKSubscription().registerSubscription()
    }
}
