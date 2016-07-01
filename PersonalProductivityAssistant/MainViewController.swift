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

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimeLogEditDelegate {
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var tableViewActivities: UITableView!
    
    let timeLogRepository = TimeLogRepository()
    var tableViewTimeLogs = [TimeLog]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewActivities.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        displayPersistedActivities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let viewControllerAddTimeLog = segue.destinationViewController as? AddTimeLogViewController {
            viewControllerAddTimeLog.timeLogEditDelegate = self
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
        
        cell.textViewActivity?.text = timeLog.activity
        cell.textViewFrom?.text = timeLog.from?.asFormattedString("dd.MM.YYYY HH:mm:ss")
        cell.textViewUntil?.text = timeLog.until?.asFormattedString("dd.MM.YYYY HH:mm:ss")
        cell.textViewDuration?.text = String(timeLog.getDurationInMinutes()) + " Minutes"
        
        return cell
    }
    
    
    // MARK: UITableViewDelegate
    var timeLogToEdit: TimeLog?
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        timeLogToEdit = tableViewTimeLogs[indexPath.row]
        
        performSegueWithIdentifier("ShowSegueToAddTimeLog", sender: self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteActivity(tableView, indexPath: indexPath)
        }
    }

    // MARK: TimeLogEditDelegate
    func timeLogAdded(timeLogData: TimeLogData) {
        addANewActivity(timeLogData)
    }
    
    func getTimeLogToEdit() -> TimeLog? {
        return timeLogToEdit
    }
    
    
    // MARK: Actions
    @IBAction func unwindToMainView(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func actionToolbarAddTimeLog(sender: AnyObject) {
        timeLogToEdit = nil
        
        performSegueWithIdentifier("ShowSegueToAddTimeLog", sender: self)
    }

    // MARK: Helper methods
    func displayPersistedActivities() {
        
        tableViewTimeLogs.removeAll()
        
        let getAllResult = timeLogRepository.getAll()
        
        guard getAllResult.isSucessful == true else {
            showAlertDialog("Error loading all time logs \(getAllResult.errorMessage)")
            return
        }
        
        if let timeLogs = getAllResult.value as [TimeLog]! {
            for timeLog in timeLogs {
                tableViewTimeLogs.append(timeLog)
            }
            
            tableViewTimeLogs.sortInPlace{ $1.activity > $0.activity }
        }
        
    }
    
    func addANewActivity(timeLogData: TimeLogData) {
        
        if let editTimeLog = timeLogToEdit {
            editTimeLog.activity = timeLogData.Activity
            editTimeLog.from = timeLogData.From
            editTimeLog.until = timeLogData.Until
            
            let saveChangesResult = timeLogRepository.save()
            
            guard saveChangesResult.isSucessful == true else {
                showAlertDialog("Error saving timrLog changes \(saveChangesResult.errorMessage)")
                return
            }
        }
        else {
            let newTimeLogResult = timeLogRepository.addNew(timeLogData)
        
            guard newTimeLogResult.isSucessful == true else {
                showAlertDialog("Error adding a new time log \(newTimeLogResult.errorMessage)")
                return
            }
            
            guard let newTimeLog = newTimeLogResult.value as TimeLog! else {
                NSLog("New TimeLog is of an unexpected type")
                return;
            }
        
            tableViewTimeLogs.append(newTimeLog)
            tableViewTimeLogs.sortInPlace{ $0.activity > $1.activity }
        }
        
        tableViewActivities.reloadData()
    }
    
    func deleteActivity(tableView: UITableView, indexPath: NSIndexPath) {
        let timeLogToDelete = tableViewTimeLogs[indexPath.row]
        let deleteRsult = timeLogRepository.delete(timeLogToDelete)
        
        guard deleteRsult.isSucessful else {
            showAlertDialog("failed to delete TimeLog \(deleteRsult.errorMessage)")
            return
        }
        
        tableViewTimeLogs.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func showAlertDialog(errorMessage: String) {
        let alertController =
            UIAlertController(
                title: "PPA",
                message: errorMessage,
                preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

