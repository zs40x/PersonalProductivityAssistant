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
    
    @IBAction func actionAddActivity(sender: AnyObject) {
        activityNames.append(textEditActivity.text!)
        tableViewActivities.reloadData()
        
        let model = PPAModel.New()
        model.createTimeLog(textEditActivity.text!)
        model.save()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableViewActivities.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        displayPersistedActivities()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func displayPersistedActivities() {
        let model = PPAModel.New()
        
        for timeLog in model.timeLogs {
          activityNames.append(timeLog.activity!)
        }
    }
}

