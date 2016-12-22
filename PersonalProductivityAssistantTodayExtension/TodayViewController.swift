//
//  TodayViewController.swift
//  PersonalProductivityAssistantTodayExtension
//
//  Created by Stefan Mehnert on 17/10/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var timeLogsToDispay = [TimeLog]()
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NSLog("viewWillAppear()")
        
        _ = updateWidgetContent()
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        NSLog("widgetActiveDisplayModeDidChange()")
       
        guard activeDisplayMode == NCWidgetDisplayMode.expanded else { return }
            
        preferredContentSize = CGSize(width: 0, height: 175)
        
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        
        NSLog("widgetPerformUpdate()")
        
        DispatchQueue.main.async {
            [unowned self] in
            
            completionHandler(self.updateWidgetContent())
        }
    }
    
    func updateWidgetContent() -> NCUpdateResult {
        
        NSLog("updateWidgetContent()")
        
        let result = TimeLogRepository().forMonthOf(Date())
        
        guard var timeLogs = result.value else { return .failed }
        
        timeLogsToDispay.removeAll()
        
        for _ in 1..<4 {
            
            guard let popped = timeLogs.popLast() else { break }
            
            timeLogsToDispay.append(popped)
        }
        
        tableView.reloadData()
        
        return .newData
    }
    
    @IBAction func actionStartActivity(_ sender: Any) {
        NSLog("Button add activity clicked")
        
        let result =
            TimeLogRepository().addNew(
                TimeLogData(
                        Uuid: UUID(),
                        Activity: "New activity",
                        From: Date(),
                        Until: Date(),
                        Hidden: NSNumber.bool_false,
                        CloudSyncPending: NSNumber.bool_true,
                        CloudSyncStatus: .New)
                    )
        
        if result.isSucessful {
            _ = updateWidgetContent()
        }
    }
}

extension TodayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = timeLogsToDispay[indexPath.row].activity
        
        return cell
    }

}

extension TodayViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeLogsToDispay.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedTimeLogUuid = timeLogsToDispay[indexPath.row].uuid else { return }
        
        guard let url = URL(string: "personal_productivity_assistant://\(selectedTimeLogUuid)") else { return }
        
        extensionContext?.open(url, completionHandler: { (success) in
            if (!success) {
                NSLog("Failed to open app with URL \(url)")
                return
            }
            
            NSLog("Opened app with URL \(url)")
        })
    }
}
