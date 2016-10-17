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
        
    @IBOutlet weak var labelHelloWorld: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateWidgetContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8.0, bottom: 0, right: 8.0)
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        updateWidgetContent()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func updateWidgetContent() {
        
        let timeLogRepository = TimeLogRepository()
        
       let result = timeLogRepository.forMonthOf(Date())
        
        guard result.isSucessful else {
            return
        }
        
        guard let firstTimeLog = result.value?.last else {
            return
        }
        
        self.labelHelloWorld.text = firstTimeLog.activity!
    }
}
