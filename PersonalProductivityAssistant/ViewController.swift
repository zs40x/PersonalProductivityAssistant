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
        let model = PPAModel.New()
        
        for timeLog in model.timeLogs {
          activityNames.append(timeLog.activity!)
        }
    }
    
    func addANewActivity(activity activityInput: String?) {
        guard let activity = activityInput else {
            NSLog("could not add a Nil activity")
            return
        }
        
        do {
            let model = PPAModel.New()
            model.createTimeLog(activity)
            model.save()
        
            activityNames.append(textEditActivity.text!)
            activityNames.sortInPlace()
        
            tableViewActivities.reloadData()
        } catch let error as NSError {
            NSLog("Error saving a TimeLog: \(error); \(error.userInfo)")
        }
    }
}

