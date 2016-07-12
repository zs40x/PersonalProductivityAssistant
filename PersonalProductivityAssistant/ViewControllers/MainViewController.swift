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

extension String {
    func findOccurencesOf(text text:String) -> [NSRange] {
        return !text.isEmpty ? try! NSRegularExpression(pattern: text, options: []).matchesInString(self, options: [], range: NSRange(0..<characters.count)).map{ $0.range } : []
    }
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SegueHandlerType, TimeLogEditDelegate {
    
    private let timeLogRepository = TimeLogRepository()
    private var tableViewTimeLogs = [TimeLog]()
    private var timeLogToEdit: TimeLog?
    
    enum SegueIdentifier : String {
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
        
        cell.textViewActivity?.attributedText = timeLog.activityAsAttributedString()
        cell.textViewFrom?.text = timeLog.from?.asFormattedString("dd.MM.YYYY HH:mm:ss")
        cell.textViewUntil?.text = timeLog.until?.asFormattedString("dd.MM.YYYY HH:mm:ss")
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
    func timeLogAdded(timeLogData: TimeLogData) {
        addANewTimeLog(timeLogData)
    }
    
    func editTimeLogData() -> TimeLogData? {
        return timeLogToEdit?.asTimeLogData()
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
        tableViewTimeLogs.sortInPlace{ $1.activity > $0.activity }
    }
    
    func addANewTimeLog(timeLogData: TimeLogData) {
        
        if let editTimeLog = timeLogToEdit {
            editTimeLog.updateFromTimeLogData(timeLogData)

            let saveChangesResult = timeLogRepository.save()
            
            if !saveChangesResult.isSucessful {
                showAlertDialog("Error saving timeLog changes \(saveChangesResult.errorMessage)")
                return
            }
        }
        else {
            let newTimeLogResult = timeLogRepository.addNew(timeLogData)
        
            if !newTimeLogResult.isSucessful {
                showAlertDialog("Error adding a new time log \(newTimeLogResult.errorMessage)")
                return
            }
            
            tableViewTimeLogs.append(newTimeLogResult.value!)
            tableViewTimeLogs.sortInPlace{ $0.activity > $1.activity }
        }
        
        tableViewActivities.reloadData()
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
}

