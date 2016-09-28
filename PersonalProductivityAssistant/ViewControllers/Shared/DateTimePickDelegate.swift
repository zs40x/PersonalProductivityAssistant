//
//  DateTimePickDelegate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 14/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

enum DatePickTargetField {
    case from
    case until
}

protocol DateTimePickDelegate {
    func confirmedPick(_ pickedDate: PickableDate, date: Date)
}
