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
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        _ = updateWidgetContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
    }
    
    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        
        DispatchQueue.main.async {
            [unowned self] in
            
            completionHandler(self.updateWidgetContent())
        }
    }
    
    func updateWidgetContent() -> NCUpdateResult {
        
        let result = TimeLogRepository().forMonthOf(Date())
        
        guard let timeLogs = result.value else { return .failed }
        
        for _ in 1..<5 {
            
            guard let popped = timeLogs.popLast() else { return }
            
            timeLogsToDispay.append(popped)
        }
        
        self.tableView.reloadData()
        
        return .newData
    }
    
    @IBAction func actionStartActivity(_ sender: Any) {
        NSLog("Button add activity clicked")
        
        let result = TimeLogRepository().addNew(
                        TimeLogData(Uuid: UUID(),
                                    Activity: "New activity",
                                    From: Date(),
                                    Until: Date(),
                                    Hidden: NSNumber.bool_false,
                                    CloudSyncPending: NSNumber.bool_true,
                                    CloudSyncStatus: .New))
        
        if result.isSucessful {
            _ = updateWidgetContent()
        }
    }
    
}
