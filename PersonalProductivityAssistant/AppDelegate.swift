//
//  AppDelegate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UNUserNotificationCenter.current().requestAuthorization(options:
            [[.alert, .sound, .badge]],
            completionHandler: {
                (granted, error) in
            
                if let error = error {
                    NSLog("Error requesting notification permissions: \(error)")
                    return
                }
                
                if(!granted) {
                    NSLog("Notifications not granted")
                }
        })
        
        UNUserNotificationCenter.current().delegate = self
        
       application.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        do {
            try PPAModel.sharedInstance().save()
        } catch let error as NSError {
            NSLog("Error saving coreData: \(error.localizedDescription)")
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        NSLog("App was opened with url \(url)")
        
        guard url.host == "show" else { return false }
        guard url.path == "/uuid" else { return false }
        guard let uuid = url.query else { return false }
        
        NSLog("Opened app via URL with uuid: \(uuid)")
        
        guard let mainViewController = MainViewController.mainViewController else { return false }
        
        mainViewController.setUuidVisible(uuid)
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let stringUserInfo = userInfo as? [String : NSObject] else {
            NSLog("Received remoteNotification with unexpected data")
            return
        }
        
        let notification = CKNotification(fromRemoteNotificationDictionary: stringUserInfo)
        
        guard notification.notificationType == .query else { return }
        
        
        timeLogCkUpdateReceived()
        
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        timeLogCkUpdateReceived()
        
        completionHandler();
    }
    
    private func timeLogCkUpdateReceived() {
        
        NSLog("Received changed records nofitication from cloudKit")
        
        
        guard let mainWindow = MainViewController.mainViewController as? CKDataSyncCompletedDelegate else { return }
        
        DispatchQueue.main.async(execute: {
            
            let timeLogsInCk = TimeLogsInCK()
            timeLogsInCk.dataSyncCompletedDelegate = mainWindow
            timeLogsInCk.importTimeLogsFromCkToDb()
        });

    }
}

