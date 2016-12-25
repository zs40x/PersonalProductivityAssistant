//
//  DateRange_asString.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 24/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant


class DateRange_asStringTest: XCTestCase {
    
    func testSameDay_onlyTheFirstDate() {
        
        let christmasDay = Date.makeDateFromComponents(day: 24, month: 12, year: 2016)
        
        XCTAssertEqual("24.12.2016", exerciseAndReturnFormattedDate(from: christmasDay, until: christmasDay))
    }
    
    func testTowDaysInSameMonth_bothDaysButMonthAndYeaeOnlyOnce() {
        
        let firstOfMonth = Date.makeDateFromComponents(day: 1, month: 12, year: 2016)
        let lastOfMonth = Date.makeDateFromComponents(day: 31, month: 12, year: 2016)
        
        XCTAssertEqual("1. - 31.12.2016", exerciseAndReturnFormattedDate(from: firstOfMonth, until: lastOfMonth))
    }
    
    private func exerciseAndReturnFormattedDate(from: Date, until: Date) -> String {
        
        return DateRange(from: from, until: until).asString()
    }
}
