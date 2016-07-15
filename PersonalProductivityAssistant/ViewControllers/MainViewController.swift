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
    @IBOutlet weak var textViewActivity: UILabel!
    @IBOutlet weak var textViewDuration: UILabel!
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SegueHandlerType, TimeLogEditDelegate {
    
    private let timeLogRepository = TimeLogRepository()
    private var tableViewTimeLogs = [TimeLog]()
    private var timeLogToEdit: TimeLog?
    
    enum SegueIdentifier: String {
        case ShowSegueToAddTimeLog
    }

    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var tableViewActivities: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewActivities.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayPersistedTimeLogs()
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

    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewTimeLogs.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCellWithIdentifier(
                "CellPrototypeActivity", forIndexPath: indexPath) as! TableViewActivityCell
        
        let timeLog = tableViewTimeLogs[indexPath.row]
        
        cell.textViewActivity?.attributedText = timeLog.activityAsAttributedString()
        cell.textViewFrom?.text = timeLog.from?.asFormattedString()
        cell.textViewUntil?.text = timeLog.until?.asFormattedString()
        cell.textViewDuration?.text = String(timeLog.durationInMinutes()) + " Minutes"
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        timeLogToEdit = tableViewTimeLogs[indexPath.row]
        
        performSegueWithIdentifier(.ShowSegueToAddTimeLog, sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            deleteTimeLog(tableView, indexPath: indexPath)
        }
    }

    
    // MARK: TimeLogEditDelegate
    func timeLogEdited(editMode: TimeLogEditMode, timeLog: TimeLogData) -> Result {
        return editedTimeLog(editMode, timeLogData: timeLog)
    }
    
    // MARK: Actions
    @IBAction func unwindToMainView(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func actionToolbarAddTimeLog(sender: AnyObject) {
        
        timeLogToEdit = nil
        
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
    
    func editedTimeLog(editMode: TimeLogEditMode, timeLogData: TimeLogData) -> Result {
        
        if editMode == TimeLogEditMode.Updated {
            
            guard let editedTimeLog = timeLogToEdit else {
                return Result.Failure("invalid timeLog")
            }
            
            editedTimeLog.updateFromTimeLogData(timeLogData)

            let saveChangesResult = timeLogRepository.save()
            
            if !timeLogRepository.save().isSucessful {
                return Result.Failure("Error saving timeLog changes \(saveChangesResult.errorMessage)")
            }
        }
        else {
            let newTimeLogResult = timeLogRepository.addNew(timeLogData)
        
            if !newTimeLogResult.isSucessful {
                return Result.Failure("Error adding a new time log \(newTimeLogResult.errorMessage)")
            }
            
            tableViewTimeLogs.append(newTimeLogResult.value!)
        }
        
        sortTimeLogTable()
        tableViewActivities.reloadData()
        
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

