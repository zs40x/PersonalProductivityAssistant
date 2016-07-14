//
//  DateTimePickDelegate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 14/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol DateTimePickDelegate {
    func dateTimePicked(fieldToPick selectedFieldToPick: SelectedDateField?, dateTime: NSDate);
}