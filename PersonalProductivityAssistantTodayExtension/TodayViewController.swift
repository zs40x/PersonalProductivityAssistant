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
        
        guard var timeLogs = result.value else { return .failed }
        
        timeLogsToDispay.removeAll()
        
        for _ in 1..<3 {
            
            guard let popped = timeLogs.popLast() else { break }
            
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

extension TodayViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = self.timeLogsToDispay[indexPath.row].activity
        
        return cell
    }

}

extension TodayViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeLogsToDispay.count
    }
}
