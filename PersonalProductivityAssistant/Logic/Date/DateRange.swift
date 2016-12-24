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
        
        return from.asFormattedString(format: Config.shortDateFormat)
    }
}
