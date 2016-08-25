//
//  NSDate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 28/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension Date {
    
    func asFormattedString(_ format: String = Config.defaultDateTimeFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func daysInMonth() -> Int {
        
        let calender = Calendar.current
        
        let dayRange =
            (calender as Calendar).range(of: .firstWeekday, in: .monthSymbols, for: self)
        
        return dayRange.length
    }
    
    func firstDayOfMonth() -> Date {
        
        let calendar = NSCalendar.current
        
        let startOfMonthDateComponents = (calendar as Calendar).components([.year, .monthSymbols], from: self)
        
        let startOfMonthDate = calendar.date(from: startOfMonthDateComponents)!
        
        let startOfMonthDateMidnight =
            (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: startOfMonthDate, options: [])!
        
        return startOfMonthDateMidnight
    }
    
    func addMonthCount(_ monthCount: Int) -> Date {
    
        let calendar = NSCalendar.current
        
        return (calendar as NSCalendar).date(byAdding: .monthSymbols, value: monthCount, to: self, options: [])!
    }
}
