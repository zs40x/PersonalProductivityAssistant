//
//  TimeLogEditDelegate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 01/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol TimeLogEditDelegate: class {
    func timeLogModified(_ withStartDate: Date)
}
