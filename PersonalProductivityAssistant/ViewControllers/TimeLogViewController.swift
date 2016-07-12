//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class TimeLogViewController: UIViewController, SegueHandlerType {
    
    private var editMode = TimeLogEditMode.New
    
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
        
        initializeUpdateModeFromDelegate()
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
            let result = delegate.timeLogEdited(editMode, timeLog: getTimeLogData())
            
            if !result.isSucessful {
                showAlertDialog(result.errorMessage)
                return
            }
            
            textEditActivity.text = ""
            performSegueWithIdentifier(.UnwindToMainView, sender: self)
        }
    }
    
    
    // MAKR: Helper Methods
    func initializeUpdateModeFromDelegate() {
        
        guard let timeEditDelegate = self.timeLogEditDelegate else {
            return
        }
        
        guard let editTimeLogData = timeEditDelegate.editTimeLogData() else {
            return
        }
        
        self.textEditActivity.text = editTimeLogData.Activity
        self.datePickerStart.date = editTimeLogData.From
        self.datePickerEnd.date = editTimeLogData.Until
        
        editMode = TimeLogEditMode.Updated
    }
    
    func getTimeLogData() -> TimeLogData {
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: datePickerStart.date,
            Until: datePickerEnd.date )
    }
}