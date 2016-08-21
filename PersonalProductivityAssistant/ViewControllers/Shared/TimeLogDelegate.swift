//
//  TimeLogEditDelegate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 01/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

enum TimeLogEditMode {
    case New
    case Update
}

protocol TimeLogEditDelegate: class {
    func timeLogEdited(editMode: TimeLogEditMode, timeLog: TimeLogData) -> Result
}