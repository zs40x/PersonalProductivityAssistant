//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class TimeLogViewController: UIViewController, SegueHandlerType {
    
    private var autoCompleteItems = [String]()
    private var dateTimeFieldToPick: DateTimeFieldToPick?
    private var dateTimeFrom: NSDate?
    private var dateTimeUntil: NSDate?
    private var hashtagAutocompleteAssistant = HashtagAutoCompleteAssistant()
    
    var timeLogDataToEdit: TimeLogData?
    weak var timeLogEditDelegate: TimeLogEditDelegate?
    var timeLogEntityPersistence: TimeLogEntityPersistence?
    
    enum SegueIdentifier : String {
        case showDatePicker
    }
    
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var buttonDateTimeUntil: UIButton!
    @IBOutlet weak var buttonDateTimeFrom: UIButton!
    @IBOutlet weak var autoCompleteTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeAutocomple()
        
        textEditActivity.resignFirstResponder()
        
        initializeViewContent()
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
        
        if let dateTimePickViewController =
                segue.destinationViewController as? DateTimePickViewController {
            
            dateTimePickViewController.delegate = self
            dateTimePickViewController.dateTimeFieldToPick = dateTimeFieldToPick
            dateTimePickViewController.selectedDateTime = getValueForDateTimeFieldToPick()
        }
    }

    
    // MARK: Actions
    @IBAction func actionAddTimeLog(sender: AnyObject) {
        view.endEditing(true)
        
        let timeLogData = getTimeLogData()
        
        guard dateTimeFrom != nil && dateTimeUntil != nil else {
            showAlertDialog("Start and end time must be provided")
            return
        }
        
        guard let persistence = timeLogEntityPersistence else {
            showAlertDialog("No Persistence set")
            return
        }
        
        guard let delegate = self.timeLogEditDelegate else {
            showAlertDialog("Delegate not initialized")
            return
        }
        
    
        let result = persistence.persist(timeLogData)
            
        if !result.isSucessful {
            showAlertDialog(result.errorMessage)
            return
        }
        
        delegate.timeLogModified(timeLogData.From)
            
        textEditActivity.text = ""
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    @IBAction func actionActivityEditingChanged(sender: AnyObject) {
        
        toggleAutoCompletevisibilityForCurrentInput()
    }
    
    @IBAction func actionTapedDateTimeStart(sender: UIButton) {
        
        self.pickDateTime(.From)
    }
    
    @IBAction func actionTappedDateTimeEnd(sender: AnyObject) {
        
        self.pickDateTime(.Until)
    }
    
    
    // MARK: Helper Methods
    func initializeAutocomple() {
        
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.hidden = true
        autoCompleteTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func initializeViewContent() {
        
        guard let editTimeLogData = self.timeLogDataToEdit else {
            initializeDefaultValues()
            return
        }
        
        self.textEditActivity.text = editTimeLogData.Activity
        self.dateTimeFrom = editTimeLogData.From
        self.dateTimeUntil = editTimeLogData.Until
        
        displayFromAndUntilDateTime()
    }
    
    func initializeDefaultValues() {
        
        self.dateTimeFrom = NSDate()
        self.dateTimeUntil = NSDate()
        
        self.displayFromAndUntilDateTime()
    }
    
    func getTimeLogData() -> TimeLogData {
        
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: dateTimeFrom!,
            Until: dateTimeUntil! )
    }
    
    func displayFromAndUntilDateTime() {
        
        self.buttonDateTimeFrom.setTitle(
            convertNSDateToReadableStringOrDefaultValue(self.dateTimeFrom), forState: .Normal)
        self.buttonDateTimeUntil.setTitle(
            convertNSDateToReadableStringOrDefaultValue(self.dateTimeUntil), forState: .Normal)
    }
    
    func convertNSDateToReadableStringOrDefaultValue(date: NSDate?) -> String {
        
        return date != nil ? date!.asFormattedString() : "n/a"
    }
    
    func pickDateTime(targetField: DateTimeFieldToPick) {
        
        dateTimeFieldToPick = targetField
        
        self.performSegueWithIdentifier(.showDatePicker, sender: self)
    }
    
    func getValueForDateTimeFieldToPick() -> NSDate? {
        
        switch dateTimeFieldToPick! {
        case .From:
            return self.dateTimeFrom
        case .Until:
            return self.dateTimeUntil
        }
    }
    
    func toggleAutoCompletevisibilityForCurrentInput() {
        
        let currentInput = self.textEditActivity.text!
     
        if hashtagAutocompleteAssistant.isAutoCompletePossible(forInputString: currentInput) {
            
            autoCompleteTableView.hidden = false
            updateAutoCompleteValues()
        }
        else {
            autoCompleteTableView.hidden = true
        }
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

extension TimeLogViewController : DateTimePickDelegate {
    
    func dateTimePicked(fieldToPick selectedDateTime: DateTimeFieldToPick?, dateTime: NSDate) {
        
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
}

extension TimeLogViewController :  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteItems.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let autoCompleteItem = autoCompleteItems[indexPath.row]
        
        let cell =
            self.autoCompleteTableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel!.text = autoCompleteItem
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let tappedHashtag = autoCompleteItems[indexPath.row]
        
        self.textEditActivity.text =
            hashtagAutocompleteAssistant.appendHastag(withName: tappedHashtag, to: self.textEditActivity.text!)
        
        self.autoCompleteTableView.hidden = true
    }
}
