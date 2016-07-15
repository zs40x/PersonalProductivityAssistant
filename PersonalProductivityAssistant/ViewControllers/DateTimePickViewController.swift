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
    var dateTimeFieldToPick: SelectedDateField?
    var selectedDateTime: NSDate?
    
    @IBOutlet weak var datePicker: UIDatePicker!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let preSelectedDateTime = self.selectedDateTime {
            self.datePicker.date = preSelectedDateTime
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionTappedUse(sender: AnyObject) {
        
        defer {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        guard dateTimeFieldToPick != nil else {
            return
        }
        
        guard let dateTimePickedDelegate = self.delegate else {
            return
        }
        
        dateTimePickedDelegate.dateTimePicked(fieldToPick: dateTimeFieldToPick, dateTime: datePicker.date)
    }
}
