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
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
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
        
        loadTimeLogs(Date())
        
        initializeCalendar()
        
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
                
                
                let dateForNewTimeLog = calendarManager.date() ?? Date()
                
                viewControllerAddTimeLog.timeLogDataToEdit =
                    TimeLogData(
                        Uuid: UUID(),
                        Activity: "",
                        From: dateForNewTimeLog,
                        Until: dateForNewTimeLog,
                        Hidden: NSNumber.bool_false,
                        CloudSyncPending: true,
                        CloudSyncStatus: .New)
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
        calendarManager.menuView = self.calendarMenuView
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
        
        
        
        DispatchQueue.main.async {
            [unowned self, tableView = tableView, indexPathToDelete = indexPath] in
            
            self.tableViewTimeLogs.remove(at: (indexPathToDelete as NSIndexPath).row)
            tableView.deleteRows(at: [indexPathToDelete], with: .automatic)
            
            self.calendarManager.reload()
            
            TimeLogsInCK().exportTimeLogsToCK()
        }
    }
    

    func loadTimeLogs(_ date: Date) {
        
        let timeLogsInMonthResult = self.timeLogRepository.forMonthOf(date)
        
        if !timeLogsInMonthResult.isSucessful {
            showAlertDialog("Error loading time logs \(timeLogsInMonthResult.errorMessage)")
            return
        }
    
        let timeLogsInMonth = timeLogsInMonthResult.value!
        
        self.tableViewTimeLogs = timeLogsInMonth
        
    }
    
    func refreshControlsAync() {
        
        DispatchQueue.main.async(execute: {
            self.tableViewActivities.reloadData()
            self.calendarManager.reload()
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



extension MainViewController : JTCalendarDelegate {
    
    func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
     
        guard let dayView = dayView as? JTCalendarDayView else { return }
        
        dayView.isHidden = false
        dayView.dotView.isHidden = true
        dayView.circleView.isHidden = true
        
        if dayView.isFromAnotherMonth {
            dayView.textLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        }
        else if calendarManager.dateHelper.date(Date(), isTheSameDayThan: dayView.date) {
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
     
        if let _ = tableViewTimeLogs.filter({
                    calendarManager.dateHelper.date($0.from, isTheSameDayThan: dayView.date) }).first {
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
    }
    
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
    }
    
    func calendar(_ calendar: JTCalendarManager!, dateForNextPageWithCurrentDate currentDate: Date!) -> Date! {
        NSLog("dateForNextPageWithCurrentDate: \(currentDate)")
        
        loadTimeLogs(currentDate)
        
        return currentDate.addMonthCount(1)
    }
    
    func calendar(_ calendar: JTCalendarManager!, dateForPreviousPageWithCurrentDate currentDate: Date!) -> Date! {
        NSLog("dateForNextPageWithCurrentDate: \(currentDate)")
        
        loadTimeLogs(currentDate)
        
        return currentDate.addMonthCount(-1)
    }
}

extension MainViewController : TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        loadTimeLogs(withStartDate)
        refreshControlsAync()
        
        let timeLogsInCk = TimeLogsInCK()
        timeLogsInCk.exportTimeLogsToCK()
    }
}


extension MainViewController : CKDataSyncCompletedDelegate {
    
    func dataSyncCompleted() {
    
        calendarManager.reload()
    }
}
