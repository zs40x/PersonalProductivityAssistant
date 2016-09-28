//
//  NSDate_firstDayOfCurrentAndNextMonth.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 17/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant

class NSDate_firstDayOfCurrentAndNextMonth: XCTestCase {
    
    let currentMonth = 8
    let nextMonth = 9
    static let currentYear = 2016
    let nextYear = 2017
    
    
    func dayInMonth(_ day: Int, month: Int, year: Int = currentYear) -> Date {
        
        let calendar = Calendar.current
        
        var dateComponents = DateComponents()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        
        return calendar.date(from: dateComponents)!
    }
    
    
    
    func testFirstDayInMonth() {
        
        let fivteenthsOfMonth = self.dayInMonth(15, month: self.currentMonth)
        let actualFirstOfMonth = fivteenthsOfMonth.firstDayOfMonth()
        let expectedFirstOfMonth = self.dayInMonth(1, month: self.currentMonth)
        
        XCTAssertEqual(expectedFirstOfMonth, actualFirstOfMonth)
    }
    
    func testAddOneMonth() {
        
        let aDay = self.dayInMonth(1, month: self.currentMonth)
        let actualDayInNextMoneth = aDay.addMonthCount(1)
        let expectedNextMonthDate = self.dayInMonth(1, month: nextMonth)
        
        XCTAssertEqual(expectedNextMonthDate, actualDayInNextMoneth)
    }
    
    func testAddMonthToChangeYear() {
        
        let aDay = self.dayInMonth(2, month: currentMonth)
        let actualDayInNextYear = aDay.addMonthCount(6)
        let expectedDateInNextYear = self.dayInMonth(2, month: 2, year: nextYear)
        
        XCTAssertEqual(expectedDateInNextYear, actualDayInNextYear)
    }
}
