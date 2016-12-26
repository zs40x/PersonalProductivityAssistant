//
//  TimeLogsInCKSubscription.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 26/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CloudKit

class TimeLogsInCKSubscription {
    
    func registerSubscription() {
        
        TimeLogsInCKSubscriptionDeletion().deleteAllSubscriptions(completionHandler: {
            
            TimeLogsInCKSubscription().registerNewTimeLogSubscription()
        })
    }
    
    private func registerNewTimeLogSubscription() {
        
        let allRecordsPredicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription =
            CKQuerySubscription(
                recordType: TimeLogsInCK.RecordTypeTimeLogs,
                predicate: allRecordsPredicate,
                options: [CKQuerySubscriptionOptions.firesOnRecordCreation,
                          CKQuerySubscriptionOptions.firesOnRecordUpdate,
                          CKQuerySubscriptionOptions.firesOnRecordDeletion])
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.alertLocalizationKey = "Changed TimeLogs"
        notificationInfo.shouldBadge = true
        notificationInfo.soundName = "default"
        subscription.notificationInfo = notificationInfo
        
        CKContainer.default().privateCloudDatabase.save(subscription, completionHandler: {
            (subscription, error) in
            
            if let error = error {
                NSLog("Subscription failed: \(error)")
                return
            }
            
            NSLog("TimeLog subscription saved")
        })
    }
}

class TimeLogsInCKSubscriptionDeletion {
    
    func deleteAllSubscriptions(completionHandler: @escaping ()->()) {
        
        CKContainer.default().privateCloudDatabase.fetchAllSubscriptions {
            [completionHandler] (subscriptions, error) in
            
            if let error = error {
                NSLog("Failed downloading existing subscriptions from iCloud: \(error.localizedDescription)")
                return
            }
            
            guard let subscriptions = subscriptions else { return }
            
            NSLog("Downloaded iCloud subscriptions")
            
            guard subscriptions.count > 0 else {
                NSLog("No existing subscriptions")
                completionHandler()
                return
            }
            
            subscriptions.forEach({
                [completionHandler] (subscription) in
                
                NSLog("Will delete subscription with ID \(subscription.subscriptionID)")
                
                CKContainer.default().privateCloudDatabase.delete(withSubscriptionID: subscription.subscriptionID, completionHandler: {
                    [completionHandler](subscriptionID, error) in
                    
                    if let error = error {
                        NSLog("Error deleting subscription with ID \(subscriptionID): \(error.localizedDescription)")
                        return
                    }
                    
                    NSLog("Successfully deleted subscription with ID \(subscriptionID)")
                    
                    CKContainer.default().privateCloudDatabase.fetchAllSubscriptions(completionHandler: {
                        [completionHandler] (subscriptions, error) in
                        
                        if let error = error {
                            NSLog("Error fetching all subscriptions the verify that all have been deleted: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let subscriptions = subscriptions else { return }
                        guard subscriptions.count == 0 else { return }
                        
                        NSLog("All existing subscriptions have beend deleted")
                        
                        completionHandler()
                    })
                })
            })
        }
    }
}
