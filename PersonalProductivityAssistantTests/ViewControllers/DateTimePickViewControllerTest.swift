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
 
    func testSetButtonNotifiesDelegate() {
        sendActionSetButtonPressed()
        
        XCTAssertNotNil(fakeDateTimePickDelegate.date)
    }
    
    func testDelegateReceivesChangedDate() {
        let selectedDate = Date()
        
        viewController.datePicker.date = selectedDate
        sendActionSetButtonPressed()
        
        XCTAssertEqual(selectedDate, fakeDateTimePickDelegate.date)
    }
    
    func testDelegateReceivesPickedDate() {
        sendActionSetButtonPressed()
        
        XCTAssertNotNil(fakeDateTimePickDelegate.pickedDate)
        XCTAssertEqual(dateToPick, fakeDateTimePickDelegate.pickedDate!)
    }
    
    
    private func sendActionSetButtonPressed() {
        UIApplication.shared.sendAction(
            viewController.navButtonSet.action!,
            to: viewController.navButtonSet.target,
            from: self,
            for: nil)
    }
}


class FakeDateTimePickDelegate: DateTimePickDelegate {
    
    var pickedDate: PickableDate?
    var date: Date?
    
    func confirmedPick(_ pickedDate: PickableDate, date: Date) {
        self.pickedDate = pickedDate
        self.date = date
    }
}
