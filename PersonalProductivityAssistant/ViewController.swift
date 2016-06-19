//
//  ViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var tableViewActivities: UITableView!
    
    let timeLogRepository = TimeLogRepository()
    var activityNames = [TimeLog]()
    

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

    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return activityNames.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
        
        cell!.textLabel!.text = activityNames[indexPath.row].activity
        
        return cell!
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteActivity(tableView, indexPath: indexPath)
        }
    }
    
    
    // MARK: Actions
    @IBAction func unwindToMainView(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func actionAddActivity(sender: AnyObject) {
        addANewActivity(activity: textEditActivity.text!)
        
        textEditActivity.text = ""
        view.endEditing(true)
    }
    
    @IBAction func actionLogTime(sender: AnyObject) {
        showAlertDialog("Test")
    }
    

    // MARK: Helper methods
    func displayPersistedActivities() {
        let getAllResult = timeLogRepository.getAll()
        
        guard getAllResult.isSucessful == true else {
            showAlertDialog("Error loading all time logs \(getAllResult.errorMessage)")
            return
        }
        
        if let timeLogs = getAllResult.value as [TimeLog]! {
            for timeLog in timeLogs {
                activityNames.append(timeLog)
            }
            
            activityNames.sortInPlace{ $0.activity > $1.activity }
        }
        
    }
    
    func addANewActivity(activity activityInput: String?) {
        
        guard let enteredActivityName = activityInput else {
            NSLog("could not add a Nil activity")
            return
        }
        
        let newTimeLogResult = timeLogRepository.addNew(enteredActivityName)
        
        guard newTimeLogResult.isSucessful == true else {
            showAlertDialog("Error adding a new time log \(newTimeLogResult.errorMessage)")
            return
        }
        
        guard let newTimeLog = newTimeLogResult.value as TimeLog! else {
            NSLog("New TimeLog is of an unexpected type")
            return;
        }
        
        activityNames.append(newTimeLog)
        activityNames.sortInPlace{ $0.activity > $1.activity }
        
        tableViewActivities.reloadData()
    }
    
    func deleteActivity(tableView: UITableView, indexPath: NSIndexPath) {
        let timeLogToDelete = activityNames[indexPath.row]
        let deleteRsult = timeLogRepository.delete(timeLogToDelete)
        
        guard deleteRsult.isSucessful else {
            showAlertDialog("failed to delete TimeLog \(deleteRsult.errorMessage)")
            return
        }
        
        activityNames.removeAtIndex(indexPath.row)
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

