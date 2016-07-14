//
//  DateTimePickViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 14/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class DateTimePickViewController: UIViewController {

    var delegate: DateTimePickDelegate?
    
    @IBOutlet weak var datePicker: UIDatePicker!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionTappedUse(sender: AnyObject) {
        
        defer {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        guard let dateTimePickedDelegate = self.delegate else {
            return
        }
        
        dateTimePickedDelegate.dateTimePicked(datePicker.date)
    }
}
