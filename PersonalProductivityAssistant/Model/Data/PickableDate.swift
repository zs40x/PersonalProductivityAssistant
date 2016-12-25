//
//  PickableDate.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 25/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class PickableDate: Equatable {
    
    fileprivate(set) var date: Date
    fileprivate(set) var title: String
    fileprivate(set) var field: DatePickTargetField
    
    init(title: String, field: DatePickTargetField, date: Date) {
        self.date = date
        self.title = title
        self.field = field
    }
    
    convenience init(title: String, field: DatePickTargetField) {
        self.init(title: title, field: field,date: Date())
    }
    
    static func ==(lhs: PickableDate, rhs: PickableDate) -> Bool {
        return
            lhs.date == rhs.date
                && lhs.title == rhs.title
                && lhs.field == rhs.field
    }
}
