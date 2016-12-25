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
    fileprivate var currentLoadedTimeLogs = [TimeLog]()
    fileprivate var timeLogToEdit: TimeLog?
    fileprivate var calendarManager = JTCalendarManager()
    fileprivate var lastCurrentDate: Date?
    fileprivate var tappedDay: Date?
    
    
    enum SegueIdentifier: String {
        case ShowSegueToAddTimeLog
    }

    
    @IBOutlet weak var tableViewActivities: UITableView!
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarView: JTHorizontalCalendarView!
    @IBOutlet weak var displayDateRange: UILabel!
    
    public static var mainViewController: MainViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MainViewController.mainViewController = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.initializeCalendar()
        
        DispatchQueue.main.async {
            self.loadTimeLogs(Date())
            self.calendarManager.reload()
        }
        
        loadTimeLogsFromCloudKitAsync()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            [unowned self] in
            
            self.hideNavigationBar()
            self.refreshControls()
        }
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
                
                
                let dateForNewTimeLog = self.tappedDay ?? Date()
                
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
        
        self.lastCurrentDate = Date()
        
        calendarManager.delegate = self
        calendarManager.menuView = self.calendarMenuView
        calendarManager.contentView = self.calendarView
        calendarManager.setDate(self.lastCurrentDate)
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
            [unowned self, tableView = tableView, indexPathToDelete = indexPath, uuid = timeLogToDelete.uuid!] in
            
            self.tableViewTimeLogs.remove(at: (indexPathToDelete as NSIndexPath).row)
            tableView.deleteRows(at: [indexPathToDelete], with: .automatic)
            
            self.currentLoadedTimeLogs =
                self.currentLoadedTimeLogs.filter({ $0.uuid != uuid })
            
            self.refreshControls()
            
            TimeLogsInCK().exportTimeLogsToCK()
        }
    }
    

    func loadTimeLogs(_ date: Date) {
        
        let timeLogsInMonthResult = self.timeLogRepository.forMonthOf(date)
        
        if !timeLogsInMonthResult.isSucessful {
            showAlertDialog("Error loading time logs \(timeLogsInMonthResult.errorMessage)")
            return
        }
    
        self.currentLoadedTimeLogs = timeLogsInMonthResult.value!
        
        self.tableViewTimeLogs =
            self.currentLoadedTimeLogs.filter({
                $0.from! >= date.startOfMonth() && $0.from! <= date.endOfMonth()
            })
    }
    
    func refreshControls() {
        
        NSLog("refreshControls")
            
        self.tableViewActivities.reloadData()
        self.updateDisplayedDateRange()
    }
    
    private func updateDisplayedDateRange() {
        
        displayDateRange.text = ""
        
        if let tappedDay = self.tappedDay {
            displayDateRange.text = tappedDay.asFormattedString(format: Config.shortDateFormat)
        }
        
        guard let firstTimeLogFrom = tableViewTimeLogs.first?.from else { return }
        guard let lastTimeLogFrom = tableViewTimeLogs.last?.from else { return }
        
        displayDateRange.text = DateRange(from: firstTimeLogFrom, until: lastTimeLogFrom).asString()
    }
    
    func setUuidVisible(_ uuid: String) {
        
        NSLog("setUuidVisible(\(uuid))")
        
        DispatchQueue.main.async {
            [unowned self] in
            
            guard let uuid = UUID.init(uuidString: uuid) else { return }
            guard let requestTimeLog = TimeLogRepository().withUUID(uuid: uuid).value else {
                NSLog("Requeset timeLog not found, uuid was: \(uuid)")
                return
            }
            guard let fromDate = requestTimeLog?.from else {
                NSLog("TimeLog has no from date")
                return
            }
            
            NSLog("Will prepare view to see timeLog with from date \(fromDate)")
            
            self.loadTimeLogs(fromDate)
            self.refreshControls()
        }
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
        dayView.textLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        if dayView.isFromAnotherMonth {
            dayView.textLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            return
        }
            
        if let _ = currentLoadedTimeLogs.filter({
            calendarManager.dateHelper.date($0.from, isTheSameDayThan: dayView.date) }
            ).first {
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
        
        else if calendarManager.dateHelper.date(Date(), isTheSameDayThan: dayView.date) {
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
            
        guard let tappedDay = self.tappedDay else { return }
        
        if calendarManager.dateHelper.date(tappedDay, isTheSameDayThan: dayView.date) {
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 0.8309050798, green: 0.9848287702, blue: 0.4713753462, alpha: 1)
        }
    }
    
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        guard let dayView = dayView as? JTCalendarDayView else { return }
        
        NSLog("calendar.didTouchDayView: \(dayView.date)")
        
        DispatchQueue.main.async {
            [unowned self, dayView] in
            
            guard let tappedDay = dayView.date else { return }
            
            self.tappedDay = tappedDay
            
            if !self.calendarManager.dateHelper.date(self.lastCurrentDate, isTheSameMonthThan: dayView.date) {
                NSLog("Selected a day in another month, updating view")
                
                if dayView.date!.compare(self.lastCurrentDate ?? Date()) == .orderedAscending {
                    self.calendarView.loadNextPageWithAnimation()
                } else {
                    self.calendarView.loadPreviousPageWithAnimation()
                }
                return
            }
            
            self.tableViewTimeLogs =
                self.currentLoadedTimeLogs.filter({
                    self.calendarManager.dateHelper.date($0.from, isTheSameDayThan: dayView.date)
                })
            
            self.refreshControls()
            self.calendarManager.reload()
        }
    }
    
    func calendarDidLoadNextPage(_ calendar: JTCalendarManager!) {
        
        self.reloadIfMonthChanged(currentDate: calendar.date())
    }
    
    func calendarDidLoadPreviousPage(_ calendar: JTCalendarManager!) {
        
        self.reloadIfMonthChanged(currentDate: calendar.date())
    }
    
    private func reloadIfMonthChanged(currentDate: Date) {
        
        DispatchQueue.main.async {
            [unowned self, currentDate] in
            
            if let lastCurrentDate = self.lastCurrentDate {
                if self.calendarManager.dateHelper.date(lastCurrentDate, isTheSameDayThan: currentDate) {
                    return
                }
            }
        
            NSLog("Reloading, currentDate has changed")
            
            self.lastCurrentDate = currentDate
            self.loadTimeLogs(currentDate)
            self.refreshControls()
        }
    }
}

extension MainViewController : TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        
        DispatchQueue.main.async {
            [unowned self, withStartDate] in
            
            self.loadTimeLogs(withStartDate)
            
            self.refreshControls()
            
            let timeLogsInCk = TimeLogsInCK()
            timeLogsInCk.exportTimeLogsToCK()
        }
    }
}

extension MainViewController : CKDataSyncCompletedDelegate {
    
    func dataSyncCompleted() {
        
        DispatchQueue.main.async {
            [unowned self] in
            
            self.loadTimeLogs(Date())
            self.refreshControls()
        }
    }
}
