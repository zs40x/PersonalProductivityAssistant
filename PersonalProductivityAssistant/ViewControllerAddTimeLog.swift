//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

protocol TimeLogAddedDelegate: class {
    func timeLogAdded(timeLog: TimeLogData)
}

class ViewControllerAddTimeLog: UIViewController {
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var datePickerStart: UIDatePicker!
    
    weak var timeLogAddedDelegate: TimeLogAddedDelegate?

    @IBOutlet weak var datePickerEnd: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textEditActivity.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
    }
    
    @IBAction func pickerValueChanged(sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func unwindToAddTimeLogView(segue: UIStoryboardSegue) {
        
    }

    @IBAction func actionAddTimeLog(sender: AnyObject) {
        view.endEditing(true)
        
        if let delegate = timeLogAddedDelegate {
            delegate.timeLogAdded(getTimeLogData())
       
            textEditActivity.text = ""
            
            performSegueWithIdentifier("UnwindToMainView", sender: self)
        }
    }
    
    func getTimeLogData() -> TimeLogData {
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: datePickerStart.date )
    }
}
