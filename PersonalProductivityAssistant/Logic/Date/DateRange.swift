//
//  DateRange.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 24/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class DateRange {
    
    var from: Date
    var until: Date
    
    init(from: Date, until: Date) {
        self.from = from
        self.until = until
    }
    
    func asString() -> String {
        
        if sameDay() {
            return from.asFormattedString(format: Config.shortDateFormat)
        }
        
        if sameMonth() {
            return "\(dayOfFrom()). - \(until.asFormattedString(format: Config.shortDateFormat))"
        }
        
        return ""
    }
    
    func sameDay() -> Bool {
        return Calendar.current.compare(from, to: until, toGranularity: .day) == .orderedSame
    }
    
    func sameMonth() -> Bool {
        return Calendar.current.compare(from, to: until, toGranularity: .month) == .orderedSame
    }
    
    func dayOfFrom() -> String {
        return String(Calendar.current.dateComponents([.day], from: from).day!)
    }
}
