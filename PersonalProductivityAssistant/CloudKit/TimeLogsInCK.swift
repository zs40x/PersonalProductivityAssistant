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
        
        let predicate = NSPredicate.init(value: true)
        let subscription = CKQuerySubscription(recordType: TimeLogsInCK.RecordTypeTimeLogs, predicate: predicate, options: [CKQuerySubscriptionOptions.firesOnRecordCreation, CKQuerySubscriptionOptions.firesOnRecordUpdate, CKQuerySubscriptionOptions.firesOnRecordDeletion])
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertLocalizationKey = "Changed TimeLogs"
        notificationInfo.shouldBadge = true
        subscription.notificationInfo = notificationInfo
        
        self.cloudKitContainer.privateCloudDatabase.save(subscription, completionHandler: {
            (subscription, error) in
            
            if let error = error {
                NSLog("Subscription failed: \(error)")
                return
            }
            
            NSLog("TimeLog subscription saved")
        })
    }
}
