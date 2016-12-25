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
        
        guard let dateToPick = dateToPick else { return }
        
        datePicker.date = dateToPick.date as Date
        
        navigationItem.title = dateToPick.title
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
