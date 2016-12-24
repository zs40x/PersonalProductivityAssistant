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
            (calender as NSCalendar).range(of: .day, in: .month, for: self)
        
        return dayRange.length
    }
    
    func firstDayOfMonth() -> Date {
        
        let calendar = Calendar.current
        
        let startOfMonthDateComponents = (calendar as NSCalendar).components([.year, .month], from: self)
        
        let startOfMonthDate = calendar.date(from: startOfMonthDateComponents)!
        
        let startOfMonthDateMidnight =
            (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: startOfMonthDate, options: [])!
        
        return startOfMonthDateMidnight
    }
    
    func addMonthCount(_ monthCount: Int) -> Date {
    
        let calendar = Calendar.current
        
        return (calendar as NSCalendar).date(byAdding: .month, value: monthCount, to: self, options: [])!
    }
    
    func makeDateFromComponents(_ day: Int, month: Int, year: Int) -> Date {
        
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar.date(from: dateComponents)!
    }
}
