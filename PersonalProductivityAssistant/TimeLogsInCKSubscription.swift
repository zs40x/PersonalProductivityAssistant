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
        
        CKContainer.default().privateCloudDatabase.fetchAllSubscriptions {
            (subscriptions, error) in
            
            if let error = error {
                NSLog("Failed downloading existing subscriptions from iCloud: \(error.localizedDescription)")
                return
            }
            
            guard let subscriptions = subscriptions else { return }
            
            NSLog("Downloaded iCloud subscriptions")
            
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
            
            // This is not okay, because the deletes of the existing subscriptions are done async and sometimes 
            // the subscription is created before the old ones are deleted. So it failes to create a new, because
            // it would create a duplicate and then the existing will be delted - the Result: no active subscription
            self.registerTimeLogSubscription()
        }
    }
    
    private func registerTimeLogSubscription() {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        
        let subscription =
            CKQuerySubscription(
                recordType: TimeLogsInCK.RecordTypeTimeLogs,
                predicate: predicate,
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
