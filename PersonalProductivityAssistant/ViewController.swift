//
//  ViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var textEditActivity: UITextField!
    @IBOutlet weak var tableViewActivities: UITableView!
    
    var activityNames = [String]()
    

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
        
        cell!.textLabel!.text = activityNames[indexPath.row]
        
        return cell!
    }
    
    
    // MARK: Actions
    @IBAction func actionAddActivity(sender: AnyObject) {
        addANewActivity(activity: textEditActivity.text!)
    }
    
    
    // MARK: Helper methods
    func displayPersistedActivities() {
        let timeLogRepository = TimeLogRepository()
        let getAllResult = timeLogRepository.getAll()
        
        guard getAllResult.isSucessful == true else {
            showAlertDialog("Error loading all time logs \(getAllResult.errorMessage)")
            return
        }
        
        if let timeLogs = getAllResult.value as [TimeLog]! {
            for timeLog in timeLogs {
                activityNames.append(timeLog.activity!)
            }
        }
        
    }
    
    func addANewActivity(activity activityInput: String?) {
        let timeLogRepository = TimeLogRepository()
        
        guard let enteredActivityName = activityInput else {
            NSLog("could not add a Nil activity")
            return
        }
        
        do {
            try timeLogRepository.addNew(enteredActivityName)
            
            activityNames.append(enteredActivityName)
            activityNames.sortInPlace()
        
            tableViewActivities.reloadData()
        } catch let error as NSError {
            showAlertDialog("Error add time log: \(error.getDefaultErrorMessage())")
        }
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

