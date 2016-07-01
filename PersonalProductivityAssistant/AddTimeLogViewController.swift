//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class AddTimeLogViewController: UIViewController, SegueHandlerType {
    
    weak var timeLogEditDelegate: TimeLogEditDelegate?
    
    enum SegueIdentifier : String {
        case UnwindToMainView
    }
    
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var datePickerStart: UIDatePicker!
    @IBOutlet weak var datePickerEnd: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textEditActivity.resignFirstResponder()
        
        if let timeEditDelegate = self.timeLogEditDelegate {
            if let editTimeLogData = timeEditDelegate.editTimeLogData() {
                self.textEditActivity.text = editTimeLogData.Activity
                self.datePickerStart.date = editTimeLogData.From
                self.datePickerEnd.date = editTimeLogData.Until
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    @IBAction func unwindToAddTimeLogView(segue: UIStoryboardSegue) {
    }

    @IBAction func actionAddTimeLog(sender: AnyObject) {
        view.endEditing(true)
        
        if let delegate = timeLogEditDelegate {
            delegate.timeLogAdded(getTimeLogData())
       
            textEditActivity.text = ""
            
            performSegueWithIdentifier(.UnwindToMainView, sender: self)
        }
    }
    
    
    // MAKR: Helper Methods
    func getTimeLogData() -> TimeLogData {
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: datePickerStart.date,
            Until: datePickerEnd.date )
    }
}
