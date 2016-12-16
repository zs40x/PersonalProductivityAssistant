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
        
        // Delete existing subscriptions
        
        self.cloudKitContainer.privateCloudDatabase.fetchAllSubscriptions {
            [unowned self] (subscriptions, error) in
            
            if let error = error {
                NSLog("Failed downloading existing subscriptions from iCloud: \(error.localizedDescription)")
                return
            }
            
            guard let subscriptions = subscriptions else { return }
            
            // self is no longer available below - maybe I should word with CkContainer.default() in general
            subscriptions.forEach({
                (subscription) in
                
                NSLog("Will delete subscription with ID \(subscription.subscriptionID)")
                
                CKContainer.default().privateCloudDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: {
                    (subscriptionID, error) in
                    
                    if let error = error {
                        NSLog("Error deleting subscription with ID \(subscriptionID): \(error.localizedDescription)")
                        return
                    }
                    
                    NSLog("Successfully deleted subscription with ID \(subscriptionID)")
                })
            })
            
            TimeLogsInCK().registerTimeLogSubscription()
        }
        
    }
    
    fileprivate func registerTimeLogSubscription() {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription =
            CKQuerySubscription(
                recordType: TimeLogsInCK.RecordTypeTimeLogs,
                predicate: predicate,
                options: [CKQuerySubscriptionOptions.firesOnRecordCreation, CKQuerySubscriptionOptions.firesOnRecordUpdate, CKQuerySubscriptionOptions.firesOnRecordDeletion])
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertLocalizationKey = "Changed TimeLogs"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
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
