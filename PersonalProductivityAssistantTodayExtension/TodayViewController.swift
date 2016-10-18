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
            
            let updateResult = self.updateWidgetContent()
            
            completionHandler(updateResult)
        }
    }
    
    func updateWidgetContent() -> NCUpdateResult {
        
        let timeLogRepository = TimeLogRepository()
        
       let result = timeLogRepository.forMonthOf(Date())
        
        guard result.isSucessful else {
            return .failed
        }
        
        guard let firstTimeLog = result.value?.last else {
            return .noData
        }
        
        self.labelHelloWorld.text = firstTimeLog.activity!
        
        return .newData
    }
}
