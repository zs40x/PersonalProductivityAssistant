//
//  DateTimePickViewControllerTest.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 25/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant


class DateTimePickViewControllerTest: XCTestCase {
    
    static let date = Date.makeDateFromComponents(day: 2015, month: 07, year: 27)
    static let title = "TitleField"
    static let targetField = DatePickTargetField.from
    
    let dateToPick = PickableDate(title: title, field: targetField, date: date)
    
    let fakeDateTimePickDelegate = FakeDateTimePickDelegate()
    var viewController = DateTimePickViewController()
    
    
    override func setUp() {
        super.setUp()
        
        viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "DateTimePickView") as! DateTimePickViewController
        
        viewController.dateToPick = dateToPick
        viewController.pickDelegate = fakeDateTimePickDelegate
        
        let _ = viewController.view
    }
    
    
    func testSelectedDateIsSetInPicker() {
        XCTAssertNotNil(viewController.datePicker)
        XCTAssertEqual(dateToPick.date, viewController.datePicker.date)
    }
}


class FakeDateTimePickDelegate: DateTimePickDelegate {
    
    func confirmedPick(_ pickedDate: PickableDate, date: Date) {
        
    }
}
