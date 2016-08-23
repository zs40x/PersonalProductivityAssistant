//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class PickableDate {
    
    private(set) var date: NSDate
    private(set) var title: String
    private(set) var field: DatePickTargetField
    
    init(title: String, field: DatePickTargetField, date: NSDate) {
        self.date = date
        self.title = title
        self.field = field
    }
    
    convenience init(title: String, field: DatePickTargetField) {
        self.init(title: title, field: field,date: NSDate())
    }
}

class TimeLogViewController: UIViewController, SegueHandlerType {
    
    private var autoCompleteItems = [String]()
    private var from: PickableDate = PickableDate(title: "From", field: .From)
    private var until: PickableDate = PickableDate(title: "Until", field: .Until)
    private var dateToPick: PickableDate?
    private var hashtagAutocompleteAssistant = HashtagAutoCompleteAssistant()
    
    var timeLogDataToEdit: TimeLogData?
    var timeLogEditDelegate: TimeLogEditDelegate?
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
            
            dateTimePickViewController.pickDelegate = self
            dateTimePickViewController.dateToPick = dateToPick
        }
    }

    
    // MARK: Actions
    @IBAction func actionAddTimeLog(sender: AnyObject) {
        view.endEditing(true)
        
        let timeLogData = getTimeLogData()
        
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
        
        self.pickDateTime(from)
    }
    
    @IBAction func actionTappedDateTimeEnd(sender: AnyObject) {
        
        self.pickDateTime(until)
    }
    
    
    // MARK: Helper Methods
    func initializeAutocomple() {
        
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.hidden = true
        autoCompleteTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func initializeViewContent() {
        
        defer {
            displayFromAndUntilDateTime()
        }
        
        guard let editTimeLogData = self.timeLogDataToEdit else {
            return
        }
        
        self.textEditActivity.text = editTimeLogData.Activity
        from = PickableDate(title: "From", field: .From, date: editTimeLogData.From)
        until = PickableDate(title: "Until", field: .Until, date: editTimeLogData.Until)
    }
    
    func getTimeLogData() -> TimeLogData {
        
        return TimeLogData(
            Activity: textEditActivity.text!,
            From: from.date,
            Until: until.date )
    }
    
    func displayFromAndUntilDateTime() {
        
        self.buttonDateTimeFrom.setTitle(
            convertNSDateToReadableStringOrDefaultValue(from.date), forState: .Normal)
        self.buttonDateTimeUntil.setTitle(
            convertNSDateToReadableStringOrDefaultValue(until.date), forState: .Normal)
    }
    
    func convertNSDateToReadableStringOrDefaultValue(date: NSDate?) -> String {
        
        return date != nil ? date!.asFormattedString() : "n/a"
    }
    
    func pickDateTime(target: PickableDate) {
        
        dateToPick = target
        
        performSegueWithIdentifier(.showDatePicker, sender: self)
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
    
    func confirmedPick(pickedDate: PickableDate, date: NSDate) {
        
        let newPickableDate = PickableDate(title: pickedDate.title, field: pickedDate.field, date: date)
        
        if pickedDate.field == .From {
            from = newPickableDate
        } else {
            until = newPickableDate
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
