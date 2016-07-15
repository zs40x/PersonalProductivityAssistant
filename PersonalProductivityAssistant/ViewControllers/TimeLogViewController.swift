//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

enum SelectedDateField {
    case From
    case Until
}

class TableViewAutoCompleteCell: UITableViewCell {
    
    var xy: Int?
    @IBOutlet weak var labelHashtag: UILabel!
}


class TimeLogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DateTimePickDelegate, SegueHandlerType {
    
    private var editMode = TimeLogEditMode.New
    private var autoCompleteItems = [String]()
    private var dateTimeFieldToPick: SelectedDateField?
    private var dateTimeFrom: NSDate?
    private var dateTimeUntil: NSDate?
    
    weak var timeLogEditDelegate: TimeLogEditDelegate?
    
    enum SegueIdentifier : String {
        case UnwindToMainView
    }
    
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var buttonDateTimeUntil: UIButton!
    @IBOutlet weak var buttonDateTimeFrom: UIButton!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.hidden = true
        autoCompleteTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        textEditActivity.resignFirstResponder()
        
        initializeDefaultValues()
        initializeUpdateModeFromDelegate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
        
        autoCompleteTableView.hidden = true
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let dateTimePickViewController = segue.destinationViewController as? DateTimePickViewController {
            dateTimePickViewController.delegate = self
            dateTimePickViewController.dateTimeFieldToPick = dateTimeFieldToPick
            
            switch dateTimeFieldToPick! {
            case .From:
                dateTimePickViewController.selectedDateTime = self.dateTimeFrom
            case .Until:
                dateTimePickViewController.selectedDateTime = self.dateTimeUntil
            }
        }
    }
    
    @IBAction func unwindToAddTimeLogView(segue: UIStoryboardSegue) {
    }

    
    // MARK: Actions
    @IBAction func actionAddTimeLog(sender: AnyObject) {
        view.endEditing(true)
        
        guard dateTimeFrom != nil else {
            return
        }
        
        guard dateTimeUntil != nil else {
            return
        }
        
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
    
    @IBAction func actionActitivityValueChanged(sender: AnyObject) {
        //autoCompleteTableView.hidden = false
    }
    
    @IBAction func actionActivityEditingChanged(sender: AnyObject) {
        
        if autoCompleteTableView.hidden {
            autoCompleteTableView.hidden = false
        }
        
        updateAutoCompleteValues()
    }
    
    @IBAction func actionTapedDateTimeStart(sender: AnyObject) {
        
        dateTimeFieldToPick = .From
        
        self.performSegueWithIdentifier("showDatePicker", sender: self)
    }
    
    @IBAction func actionTappedDateTimeEnd(sender: AnyObject) {
        
        
        dateTimeFieldToPick = .Until
        
        self.performSegueWithIdentifier("showDatePicker", sender: self)
    }
    
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteItems.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let autoCompleteItem = autoCompleteItems[indexPath.row]
        
        let cell = self.autoCompleteTableView.dequeueReusableCellWithIdentifier("cell")!

        cell.textLabel!.text = autoCompleteItem
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    
    // MARK: DateTimePickedDelegate
    func dateTimePicked(fieldToPick selectedDateTime: SelectedDateField?, dateTime: NSDate) {
        
        guard let dateField = selectedDateTime else {
            return
        }
        
        switch dateField {
        case .From:
            self.dateTimeFrom = dateTime
        case .Until:
            self.dateTimeUntil = dateTime
        }
        
        displayFromAndUntilDateTime()
    }
    
    
    // MARK: Helper Methods
    func initializeDefaultValues() {
        self.dateTimeFrom = NSDate()
        self.dateTimeUntil = NSDate()
        
        self.displayFromAndUntilDateTime()
    }
    
    func initializeUpdateModeFromDelegate() {
        
        guard let timeEditDelegate = self.timeLogEditDelegate else {
            return
        }
        
        guard let editTimeLogData = timeEditDelegate.editTimeLogData() else {
            return
        }
        
        
        self.textEditActivity.text = editTimeLogData.Activity
        
        self.dateTimeFrom = editTimeLogData.From
        self.dateTimeUntil = editTimeLogData.Until
        displayFromAndUntilDateTime()
        
        
        self.editMode = TimeLogEditMode.Updated
    }
    
    func getTimeLogData() -> TimeLogData {
        
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: dateTimeFrom!,
            Until: dateTimeUntil! )
    }
    
    func displayFromAndUntilDateTime() {
        
        self.buttonDateTimeFrom.setTitle(convertNSDateToReadableStringOrDefaultValue(self.dateTimeFrom), forState: .Normal)
        self.buttonDateTimeUntil.setTitle(convertNSDateToReadableStringOrDefaultValue(self.dateTimeUntil), forState: .Normal)
    }
    
    func convertNSDateToReadableStringOrDefaultValue(date: NSDate?) -> String {
        
        return date != nil ? date!.asFormattedString() : "n/a"
    }
    
    func updateAutoCompleteValues() {
        
        autoCompleteItems.removeAll()
        
        let getAllHashtagsResult = HashtagRepository().getAll()
        
        guard getAllHashtagsResult.isSucessful else {
            showAlertDialog(getAllHashtagsResult.errorMessage)
            return
        }
        
        if let allHashtags = getAllHashtagsResult.value {
            for hashtag in allHashtags {
                autoCompleteItems.append(hashtag.name!)
            }
        }
        
        self.autoCompleteTableView.reloadData()
    }
}
