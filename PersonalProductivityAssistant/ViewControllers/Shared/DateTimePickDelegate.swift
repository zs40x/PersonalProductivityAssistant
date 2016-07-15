//
//  DateTimePickDelegate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 14/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

enum DateTimeFieldToPick {
    case From
    case Until
}

protocol DateTimePickDelegate {
    func dateTimePicked(fieldToPick selectedFieldToPick: DateTimeFieldToPick?, dateTime: NSDate);
}