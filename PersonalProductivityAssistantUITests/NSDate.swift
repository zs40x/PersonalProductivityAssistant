//
//  NSDate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension NSDate {
    static func getCurrentDateTimeAsFormattedString(format: String = "dd.MM.YYYY HH:mm:ss") -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(NSDate())
    }
}