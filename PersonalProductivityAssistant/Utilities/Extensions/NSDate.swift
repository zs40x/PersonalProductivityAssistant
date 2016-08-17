//
//  NSDate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 28/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension NSDate {
    
    func asFormattedString(format: String = Config.defaultDateTimeFormat) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
    
    func daysInMonth() -> Int {
        
        let calender = NSCalendar.currentCalendar()
        
        let dayRange =
            calender.rangeOfUnit(.Day, inUnit: .Month, forDate: self)
        
        return dayRange.length
    }
    
    func firstDayOfMonth() -> NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        
        let startOfMonthDateComponents = calendar.components([.Year, .Month], fromDate: self)
        
        let startOfMonthDate = calendar.dateFromComponents(startOfMonthDateComponents)!
        
        let startOfMonthDateMidnight =
            calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: startOfMonthDate, options: [])!
        
        return startOfMonthDateMidnight
    }
    
    func addMonthCount(monthCount: Int) -> NSDate {
    
        let calendar = NSCalendar.currentCalendar()
        
        return calendar.dateByAddingUnit(.Month, value: monthCount, toDate: self, options: [])!
    }
}