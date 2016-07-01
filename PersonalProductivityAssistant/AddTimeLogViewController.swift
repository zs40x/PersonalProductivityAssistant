//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

protocol TimeLogEditDelegate: class {
    func timeLogAdded(timeLog: TimeLogData)
    func getTimeLogToEdit() -> TimeLog?
}

class AddTimeLogViewController: UIViewController, SegueHandlerType {
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var datePickerStart: UIDatePicker!
    @IBOutlet weak var datePickerEnd: UIDatePicker!
    
    weak var timeLogEditDelegate: TimeLogEditDelegate?
    
    enum SegueIdentifier : String {
        case UnwindToMainView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textEditActivity.resignFirstResponder()
        
        if let timeEditDelegate = self.timeLogEditDelegate {
            if let timeLogToEdit = timeEditDelegate.getTimeLogToEdit() {
                self.textEditActivity.text = timeLogToEdit.activity
                self.datePickerStart.date = timeLogToEdit.from!
                self.datePickerEnd.date = timeLogToEdit.until!
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
    
    @IBAction func pickerValueChanged(sender: AnyObject) {
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
    
    func getTimeLogData() -> TimeLogData {
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: datePickerStart.date,
            Until: datePickerEnd.date )
    }
}
