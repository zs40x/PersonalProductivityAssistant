//
//  NSDate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 28/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension Date {
    
    func asFormattedString(format: String = Config.defaultDateTimeFormat) -> String {
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
    
    func startOfMonth() -> Date {
        // ToDo - timeZone!?
        let startOfMonthDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
        
        let startOfMonthDateMidnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startOfMonthDate)!
        
        return startOfMonthDateMidnight
    }
    
    func endOfMonth() -> Date {
        // ToDo - timeZone!?
        let endOfMonthDate = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
        
        let endOfMontDateMidnight = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonthDate)!
        
        return endOfMontDateMidnight
    }
    
    func addMonthCount(_ monthCount: Int) -> Date {
    
        let calendar = Calendar.current
        
        return (calendar as NSCalendar).date(byAdding: .month, value: monthCount, to: self, options: [])!
    }
    
    static func makeDateFromComponents(day: Int, month: Int, year: Int) -> Date {
        
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar.date(from: dateComponents)!
    }
}
