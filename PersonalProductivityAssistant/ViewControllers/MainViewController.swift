//
//  ViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import JTCalendar

class TableViewActivityCell : UITableViewCell {
    @IBOutlet weak var textViewUntil: UILabel!
    @IBOutlet weak var textViewFrom: UILabel!
    @IBOutlet weak var textViewActivity: UITextView!
    @IBOutlet weak var textViewDuration: UILabel!
}


class MainViewController: UIViewController, SegueHandlerType {
    
    fileprivate let timeLogRepository = TimeLogRepository()
    fileprivate var tableViewTimeLogs = [TimeLog]()
    fileprivate var timeLogToEdit: TimeLog?
    fileprivate var calendarManager = JTCalendarManager()
    
    enum SegueIdentifier: String {
        case ShowSegueToAddTimeLog
    }

    
    @IBOutlet weak var tableViewActivities: UITableView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    
    public static var mainViewController: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.mainViewController = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        loadTimeLogsFromCloudKitAsync()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initializeCalendar()
        
        hideNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let viewControllerAddTimeLog = segue.destination as? TimeLogViewController {
            viewControllerAddTimeLog.timeLogEditDelegate = self
            
            if timeLogToEdit != nil {
                viewControllerAddTimeLog.timeLogEntityPersistence = UpdateTimeLogEntity(timeLog: timeLogToEdit!)
                
                viewControllerAddTimeLog.timeLogDataToEdit = timeLogToEdit?.asTimeLogData()
            } else {
                viewControllerAddTimeLog.timeLogEntityPersistence = AddNewTimeLogEntity()
                
                
                /*let dateForNewTimeLog = self.calendarView.selectedDates.first ?? Date()
                
                viewControllerAddTimeLog.timeLogDataToEdit =
                    TimeLogData(
                        Uuid: UUID(),
                        Activity: "",
                        From: dateForNewTimeLog,
                        Until: dateForNewTimeLog,
                        Hidden: NSNumber.bool_false,
                        CloudSyncPending: true,
                        CloudSyncStatus: .New)*/
            }
        }
    }

    
    // MARK: Actions
    @IBAction func actionToolbarAddTimeLog(_ sender: AnyObject) {
        
        timeLogToEdit = nil
        
        showNavigationBar()
        
        performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
    }
    

    // MARK: Helper methods
    func initializeCalendar() {
        
        calendarManager.delegate = self
        calendarManager.contentView = self.calendarView
        calendarManager.setDate(Date())
    }
    
    func deleteTimeLog(_ tableView: UITableView, indexPath: IndexPath) {
        
        let timeLogToDelete = tableViewTimeLogs[(indexPath as NSIndexPath).row]
        
        timeLogToDelete.hidden = NSNumber.bool_true
        timeLogToDelete.cloudSyncStatus = .Modified
        timeLogToDelete.cloudSyncPending = NSNumber.bool_true
        
        let saveResult = timeLogRepository.save()
        
        if !saveResult.isSucessful {
            showAlertDialog("Failed to delete TimeLog \(saveResult.errorMessage)")
            return
        } else {
            NSLog("Updated timeLog as hidden, because it was deleted by the user: \(timeLogToDelete.uuid)")
        }
        
        tableViewTimeLogs.remove(at: (indexPath as NSIndexPath).row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        /*
        ToDo Migrate
        calendarView.timeLogs = tableViewTimeLogs
        calendarView.reloadData()*/
        
        DispatchQueue.main.async {
            TimeLogsInCK().exportTimeLogsToCK()
        }
    }
    
    func updateViewForDate(_ date: Date) {
        
        let timeLogsInMonthResult = self.timeLogRepository.forMonthOf(date)
        
        if !timeLogsInMonthResult.isSucessful {
            showAlertDialog("Error loading time logs \(timeLogsInMonthResult.errorMessage)")
            return
        }
    
        let timeLogsInMonth = timeLogsInMonthResult.value!
        
        self.tableViewTimeLogs = timeLogsInMonth
        
        // ToDo: Migrate
        //self.calendarView.timeLogs = timeLogsInMonth
        
        DispatchQueue.main.async(execute: {
            self.tableViewActivities.reloadData()
            
            // ToDo: Migrate
            //self.calendarView.reloadData()
        });
    }
    
    func loadTimeLogsFromCloudKitAsync() {
        
        DispatchQueue.main.async(execute: {
            
            let timeLogsInCk = TimeLogsInCK()
            timeLogsInCk.dataSyncCompletedDelegate = self
            timeLogsInCk.importTimeLogsFromCkToDb()
            timeLogsInCk.registerTimeLogChanges()
        });
    }
}


extension MainViewController : UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewTimeLogs.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: "CellPrototypeActivity", for: indexPath) as! TableViewActivityCell
        
        let timeLog = tableViewTimeLogs[(indexPath as NSIndexPath).row]
        
        if let activity = timeLog.activity {
            cell.textViewActivity?.setTextWithHashtagLinks(activity)
        }
        else {
            cell.textViewActivity.setTextWithHashtagLinks("n/a")
        }
        
        cell.textViewActivity?.isSelectable = true
        cell.textViewActivity?.delegate = self
        cell.textViewActivity?.contentInset = UIEdgeInsetsMake(0,-4,0,0);
        cell.textViewActivity?.textContainerInset = UIEdgeInsets.zero
        let tap = UITapGestureRecognizer(target: self, action: #selector(textViewActiviyTapped))
        cell.textViewActivity.addGestureRecognizer(tap)
        
        cell.textViewFrom?.text = timeLog.from?.asFormattedString()
        cell.textViewUntil?.text = timeLog.until?.asFormattedString()
        cell.textViewDuration?.text = String(timeLog.durationInMinutes()) + " Minutes"
        
        return cell
    }
    
    func textViewActiviyTapped(_ sender: UITapGestureRecognizer) {
        
        let touch = sender.location(in: self.tableViewActivities)
        
        if let indexPath = self.tableViewActivities.indexPathForRow(at: touch) {
            
            timeLogToEdit = tableViewTimeLogs[(indexPath as NSIndexPath).row]
            
            showNavigationBar()
            
            performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        let tappedHashtag =
            textView.attributedText.attributedSubstring(from: characterRange).string
        
        showAlertDialog(tappedHashtag)
        
        return false
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        timeLogToEdit = tableViewTimeLogs[(indexPath as NSIndexPath).row]
        
        showNavigationBar()
        
        performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteTimeLog(tableView, indexPath: indexPath)
        }
    }
}


/*extension MainViewController : CalendarViewDataSource, CalendarViewDelegate {
    
    func startDate() -> Date? {
        
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        let today = Date()
        
        let threeMonthsAgo = (self.calendarView.calendar as Calendar).date(byAdding: dateComponents, to: today)
        
        
        return threeMonthsAgo
    }
    
    func endDate() -> Date? {
        
        var dateComponents = DateComponents()
        
        dateComponents.year = 2;
        let today = Date()
        
        let twoYearsFromNow = (self.calendarView.calendar as Calendar).date(byAdding: dateComponents, to: today)
        
        return twoYearsFromNow
        
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let width = self.view.frame.size.width - 16.0 * 2
        let height = width
        self.calendarView.frame = CGRect(x: ((self.view.frame.width - width) / 2), y: 0.0, width: width, height: height)
    }
    
    
    func calendar(_ calendar: CalendarView, didSelectDate date : Date, with selectedTimeLogs: [TimeLog]) {
        
        NSLog("Calender.didSelectDate: \(date), with \(selectedTimeLogs.count) timeLogs")
        
        self.tableViewTimeLogs = selectedTimeLogs
        self.tableViewActivities.reloadData()
    }
    
    func calendar(_ calendar: CalendarView, didScrollToMonth date : Date) {
        
        NSLog("Calender.didScrollToMonth: \(date)")
      
        updateViewForDate(date)
    }
}*/

extension MainViewController : JTCalendarDelegate {
    
    func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
     
        guard let dayView = dayView as? JTCalendarDayView else { return }
        
        dayView.isHidden = false
        
        if dayView.isFromAnotherMonth {
            dayView.textLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        else if calendarManager.dateHelper.date(Date(), isTheSameDayThan: dayView.date) {
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
    }
    
}

extension MainViewController : TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        updateViewForDate(withStartDate)
        
        let timeLogsInCk = TimeLogsInCK()
        timeLogsInCk.exportTimeLogsToCK()
    }
}


extension MainViewController : CKDataSyncCompletedDelegate {
    
    func dataSyncCompleted() {
    
        // ToDo: Migrate
        //updateViewForDate(self.calendarView.displayDate!)
    }
}
