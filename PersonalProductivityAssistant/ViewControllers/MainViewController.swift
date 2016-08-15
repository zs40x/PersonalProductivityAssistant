//
//  ViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class TableViewActivityCell : UITableViewCell {
    @IBOutlet weak var textViewUntil: UILabel!
    @IBOutlet weak var textViewFrom: UILabel!
    @IBOutlet weak var textViewActivity: UITextView!
    @IBOutlet weak var textViewDuration: UILabel!
}


class MainViewController: UIViewController, SegueHandlerType {
    
    private let timeLogRepository = TimeLogRepository()
    private var tableViewTimeLogs = [TimeLog]()
    private var timeLogToEdit: TimeLog?
    
    enum SegueIdentifier: String {
        case ShowSegueToAddTimeLog
    }

    
    @IBOutlet weak var tableViewActivities: UITableView!
    @IBOutlet weak var calendarView: CalendarView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayPersistedTimeLogs()
        displayCalender()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let viewControllerAddTimeLog = segue.destinationViewController as? TimeLogViewController {
            viewControllerAddTimeLog.timeLogEditDelegate = self
            viewControllerAddTimeLog.timeLogDataToEdit = timeLogToEdit?.asTimeLogData()
        }
    }

    
    // MARK: Actions
    @IBAction func actionToolbarAddTimeLog(sender: AnyObject) {
        
        timeLogToEdit = nil
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
    }
    

    // MARK: Helper methods
    func displayPersistedTimeLogs() {
        
        tableViewTimeLogs.removeAll()
        
        let getAllResult = timeLogRepository.getAll()
        
        if !getAllResult.isSucessful {
            showAlertDialog("Error loading time logs \(getAllResult.errorMessage)")
            return
        }
        
        tableViewTimeLogs.appendContentsOf(getAllResult.value!)
        sortTimeLogTable()
    }
    
    func displayCalender() {
        
        calendarView.dataSource = self
        calendarView.delegate = self
    }
    
    func editedTimeLog(editMode: TimeLogEditMode, timeLogData: TimeLogData) -> Result {
        
        switch editMode {
            
            case .Updated:
            
                guard let editedTimeLog = timeLogToEdit else {
                    return Result.Failure("invalid timeLog")
                }
            
                editedTimeLog.updateFromTimeLogData(timeLogData)

                let saveChangesResult = timeLogRepository.save()
                
                if !timeLogRepository.save().isSucessful {
                    return Result.Failure("Error saving timeLog changes \(saveChangesResult.errorMessage)")
                }
        
            case.New:
                
                let newTimeLogResult = timeLogRepository.addNew(timeLogData)
        
                if !newTimeLogResult.isSucessful {
                    return Result.Failure("Error adding a new time log \(newTimeLogResult.errorMessage)")
                }
            
                tableViewTimeLogs.append(newTimeLogResult.value!)
        }
        
        sortTimeLogTable()
        tableViewActivities.reloadData()
        calendarView.reloadData()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        return Result.Success()
    }
    
    func deleteTimeLog(tableView: UITableView, indexPath: NSIndexPath) {
        
        let timeLogToDelete = tableViewTimeLogs[indexPath.row]
        let deleteResult = timeLogRepository.delete(timeLogToDelete)
        
        if !deleteResult.isSucessful {
            showAlertDialog("Failed to delete TimeLog \(deleteResult.errorMessage)")
            return
        }
        
        tableViewTimeLogs.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func sortTimeLogTable() {
        tableViewTimeLogs.sortInPlace{ $0.activity > $1.activity }
    }
}


extension MainViewController : UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewTimeLogs.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCellWithIdentifier(
                "CellPrototypeActivity", forIndexPath: indexPath) as! TableViewActivityCell
        
        let timeLog = tableViewTimeLogs[indexPath.row]
        
        if let activity = timeLog.activity {
            cell.textViewActivity?.setTextWithHashtagLinks(activity)
        }
        else {
            cell.textViewActivity.setTextWithHashtagLinks("n/a")
        }
        
        cell.textViewActivity?.selectable = true
        cell.textViewActivity?.delegate = self
        cell.textViewActivity?.contentInset = UIEdgeInsetsMake(0,-4,0,0);
        cell.textViewActivity?.textContainerInset = UIEdgeInsetsZero
        let tap = UITapGestureRecognizer(target: self, action: #selector(textViewActiviyTapped))
        cell.textViewActivity.addGestureRecognizer(tap)
        
        cell.textViewFrom?.text = timeLog.from?.asFormattedString()
        cell.textViewUntil?.text = timeLog.until?.asFormattedString()
        cell.textViewDuration?.text = String(timeLog.durationInMinutes()) + " Minutes"
        
        return cell
    }
    
    func textViewActiviyTapped(sender: UITapGestureRecognizer) {
        
        let touch = sender.locationInView(self.tableViewActivities)
        
        if let indexPath = self.tableViewActivities.indexPathForRowAtPoint(touch) {
            
            timeLogToEdit = tableViewTimeLogs[indexPath.row]
            
            
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
        }
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        let tappedHashtag =
            textView.attributedText.attributedSubstringFromRange(characterRange).string
        
        showAlertDialog(tappedHashtag)
        
        return false
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        timeLogToEdit = tableViewTimeLogs[indexPath.row]
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            deleteTimeLog(tableView, indexPath: indexPath)
        }
    }
}


extension MainViewController : CalendarViewDataSource, CalendarViewDelegate {
    
    func startDate() -> NSDate? {
        
        let dateComponents = NSDateComponents()
        dateComponents.month = -1
        
        let today = NSDate()
        
        let threeMonthsAgo = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        
        
        return threeMonthsAgo
    }
    
    func endDate() -> NSDate? {
        
        let dateComponents = NSDateComponents()
        
        dateComponents.year = 2;
        let today = NSDate()
        
        let twoYearsFromNow = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        
        return twoYearsFromNow
        
    }
    
    func timeLogs() -> [TimeLog]? {
        let getAllResult = timeLogRepository.getAll()
        
        if !getAllResult.isSucessful {
            showAlertDialog("Error loading time logs \(getAllResult.errorMessage)")
            return nil
        }
        
        return getAllResult.value!.sort({ $0.from?.compare($1.from!) == NSComparisonResult.OrderedAscending })
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let width = self.view.frame.size.width - 16.0 * 2
        let height = width
        self.calendarView.frame = CGRect(x: ((self.view.frame.width - width) / 2), y: 0.0, width: width, height: height)
        
        self.calendarView.reloadData()
    }
    
    
    func calendar(calendar: CalendarView, didSelectDate date : NSDate, with selectedTimeLogs: [TimeLog]) {
        
        //showAlertDialog("Selected \(date), TimeLogs: \(selectedTimeLogs.count)")
        self.tableViewTimeLogs = selectedTimeLogs
        self.tableViewActivities.reloadData()
    }
    
    func calendar(calendar: CalendarView, didScrollToMonth date : NSDate) {
        
    }
}


extension MainViewController : TimeLogEditDelegate {
    
    func timeLogEdited(editMode: TimeLogEditMode, timeLog: TimeLogData) -> Result {
        return editedTimeLog(editMode, timeLogData: timeLog)
    }
}