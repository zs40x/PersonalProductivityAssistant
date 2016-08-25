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
    
    func firstDayOfMonth() -> Date {
        
        let calendar = Calendar.current
        
        let startOfMonthDateComponents = calendar.dateComponents([.year, .month], from: self)
        
        let startOfMonthDate = calendar.date(from: startOfMonthDateComponents)!
        
        let startOfMonthDateMidnight =
            (calendar as NSCalendar).date(bySettingHour: 0, minute: 0, second: 0, of: startOfMonthDate, options: [])!
        
        return startOfMonthDateMidnight
    }
    
    func addMonthCount(_ monthCount: Int) -> Date {
    
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .month, value: monthCount, to: self)!
    }
}
