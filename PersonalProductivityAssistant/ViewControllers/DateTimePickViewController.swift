//
//  DateTimePickViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 14/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class DateTimePickViewController: UIViewController {

    weak var dateToPick: PickableDate?
    var pickDelegate: DateTimePickDelegate?
    var selectedDateTime: Date?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var navButtonSet: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let target = dateToPick else { fatalError() }
        
        datePicker.date = target.date as Date
        
        navigationItem.title = target.title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func actionTappedUse(_ sender: AnyObject) {
        
        defer {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        guard let pickedDate = dateToPick else { return }
        
        guard let delegate = pickDelegate else { return }
        
        delegate.confirmedPick(pickedDate, date: datePicker.date)
    }
}
