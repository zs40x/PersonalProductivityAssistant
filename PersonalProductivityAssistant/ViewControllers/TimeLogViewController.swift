//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class PickableDate {
    
    fileprivate(set) var date: Date
    fileprivate(set) var title: String
    fileprivate(set) var field: DatePickTargetField
    
    init(title: String, field: DatePickTargetField, date: Date) {
        self.date = date
        self.title = title
        self.field = field
    }
    
    convenience init(title: String, field: DatePickTargetField) {
        self.init(title: title, field: field,date: Date())
    }
}

class TimeLogViewController: UIViewController, SegueHandlerType {
    
    fileprivate var autoCompleteItems = [String]()
    fileprivate var from: PickableDate = PickableDate(title: "From", field: .from)
    fileprivate var until: PickableDate = PickableDate(title: "Until", field: .until)
    fileprivate var dateToPick: PickableDate?
    fileprivate var hashtagAutocompleteAssistant = HashtagAutoCompleteAssistant()
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        autoCompleteTableView.isHidden = true
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let dateTimePickViewController =
                segue.destination as? DateTimePickViewController {
            
            dateTimePickViewController.pickDelegate = self
            dateTimePickViewController.dateToPick = dateToPick
        }
    }

    
    // MARK: Actions
    @IBAction func actionAddTimeLog(_ sender: AnyObject) {
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
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func actionActivityEditingChanged(_ sender: AnyObject) {
        
        toggleAutoCompletevisibilityForCurrentInput()
    }
    
    @IBAction func actionTapedDateTimeStart(_ sender: UIButton) {
        
        self.pickDateTime(from)
    }
    
    @IBAction func actionTappedDateTimeEnd(_ sender: AnyObject) {
        
        self.pickDateTime(until)
    }
    
    
    // MARK: Helper Methods
    func initializeAutocomple() {
        
        autoCompleteTableView.delegate = self
        autoCompleteTableView.dataSource = self
        autoCompleteTableView.isHidden = true
        autoCompleteTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func initializeViewContent() {
        
        defer {
            displayFromAndUntilDateTime()
        }
        
        guard let editTimeLogData = self.timeLogDataToEdit else {
            return
        }
        
        self.textEditActivity.text = editTimeLogData.Activity
        from = PickableDate(title: "From", field: .from, date: editTimeLogData.From)
        until = PickableDate(title: "Until", field: .until, date: editTimeLogData.Until)
    }
    
    func getTimeLogData() -> TimeLogData {
        
        return TimeLogData(
            UUID: timeLogDataToEdit?.UUID ?? UUID(),
            Activity: textEditActivity.text!,
            From: from.date,
            Until: until.date )
    }
    
    func displayFromAndUntilDateTime() {
        
        buttonDateTimeFrom.setTitle(dateAsFormattedString(from.date), for: UIControlState())
        buttonDateTimeUntil.setTitle(dateAsFormattedString(until.date), for: UIControlState())
    }
    
    func dateAsFormattedString(_ date: Date?) -> String {
        
        return date != nil ? date!.asFormattedString() : "n/a"
    }
    
    func pickDateTime(_ target: PickableDate) {
        
        dateToPick = target
        
        performSegueWithIdentifier(.showDatePicker, sender: self)
    }
    
    func toggleAutoCompletevisibilityForCurrentInput() {
        
        let currentInput = self.textEditActivity.text!
     
        if hashtagAutocompleteAssistant.isAutoCompletePossible(forInputString: currentInput) {
            
            autoCompleteTableView.isHidden = false
            updateAutoCompleteValues()
        }
        else {
            autoCompleteTableView.isHidden = true
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
    
    func confirmedPick(_ pickedDate: PickableDate, date: Date) {
        
        let newPickableDate = PickableDate(title: pickedDate.title, field: pickedDate.field, date: date)
        
        if pickedDate.field == .from {
            from = newPickableDate
        } else {
            until = newPickableDate
        }
        
        displayFromAndUntilDateTime()
    }
}

extension TimeLogViewController :  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoCompleteItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let autoCompleteItem = autoCompleteItems[(indexPath as NSIndexPath).row]
        
        let cell =
            self.autoCompleteTableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel!.text = autoCompleteItem
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let tappedHashtag = autoCompleteItems[(indexPath as NSIndexPath).row]
        
        self.textEditActivity.text =
            hashtagAutocompleteAssistant.appendHastag(withName: tappedHashtag, to: self.textEditActivity.text!)
        
        self.autoCompleteTableView.isHidden = true
    }
}
