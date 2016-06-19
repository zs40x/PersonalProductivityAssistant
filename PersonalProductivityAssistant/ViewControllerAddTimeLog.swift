//
//  ViewControllerAddTimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 19/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

struct TimeLogData {
    var Activity: String
}

protocol TimeLogAddedDelegate: class {
    func timeLogAdded(timeLog: TimeLogData)
}

class ViewControllerAddTimeLog: UIViewController {
    
    @IBOutlet weak var textEditActivity: UITextField!
    
    weak var timeLogAddedDelegate: TimeLogAddedDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func unwindToAddTimeLogView(segue: UIStoryboardSegue) {
        
    }

    @IBAction func actionAddTimeLog(sender: AnyObject) {
        view.endEditing(true)
        
        if let delegate = timeLogAddedDelegate {
            delegate.timeLogAdded(getTimeLogData())
       
            textEditActivity.text = ""
            
            performSegueWithIdentifier("UnwindToMainView", sender: self)
        }
    }
    
    
    func getTimeLogData() -> TimeLogData {
        return TimeLogData(Activity: textEditActivity.text!)
    }
}
