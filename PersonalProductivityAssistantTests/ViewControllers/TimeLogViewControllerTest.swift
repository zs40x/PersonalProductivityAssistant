//
//  TimeLogViewControllerTest.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 25/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant


class TimeLogViewControllerTest: XCTestCase {
    
    let timeLogData =
        TimeLogData(
                Activity: "anActivity",
                From: Date.makeDateFromComponents(day: 24, month: 12, year: 2016),
                Until: Date.makeDateFromComponents(day: 25, month: 12, year: 2016)
            )
    let pickedDate = Date.makeDateFromComponents(day: 29, month: 07, year: 2016)
    
    let fakeTimeLogEditDelegate = FakeTimeLogEditDelegate()
    let fakeTimeLogEntityPersistence = FakeTimeLogEntityPersistence()
    var viewController = TimeLogViewController()
    
    
    override func setUp() {
        super.setUp()
        
        viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "TimeLogView") as! TimeLogViewController
        
        viewController.timeLogDataToEdit = timeLogData
        viewController.timeLogEditDelegate = fakeTimeLogEditDelegate
        viewController.timeLogEntityPersistence = fakeTimeLogEntityPersistence
        
        let _ = viewController.view
    }
    
    
    func testDisplaysActivity() {
        XCTAssertNotNil(viewController.textEditActivity?.text)
        XCTAssertEqual(timeLogData.Activity, viewController.textEditActivity.text)
    }
    
    func testDisplaysFrom() {
        XCTAssertNotNil(viewController.buttonDateTimeFrom?.titleLabel)
        XCTAssertEqual(timeLogData.From.asFormattedString(), viewController.buttonDateTimeFrom.titleLabel!.text)
    }
    
    func testDisplaysUntil() {
        XCTAssertNotNil(viewController.buttonDateTimeUntil?.titleLabel)
        XCTAssertEqual(timeLogData.Until.asFormattedString(), viewController.buttonDateTimeUntil.titleLabel!.text)
    }
    
    
    func testPickedDateChangesFromButtonText() {
        viewController.confirmedPick(PickableDate(title: "", field: .from, date: timeLogData.From), date: pickedDate)
    
        XCTAssertEqual(pickedDate.asFormattedString(), viewController.buttonDateTimeFrom.titleLabel!.text)
    }
    
    func testPickedDateChangesUntilButtonText() {
        viewController.confirmedPick(PickableDate(title: "", field: .until, date: timeLogData.Until), date: pickedDate)
        
        XCTAssertEqual(pickedDate.asFormattedString(), viewController.buttonDateTimeUntil.titleLabel!.text)
    }
    
    func testPickedFromDateAfterUntilChangedUntil() {
        let pickedDate = Date.makeDateFromComponents(day: 26, month: 12, year: 2016)
        
        viewController.confirmedPick(PickableDate(title: "", field: .from), date: pickedDate)
        
        XCTAssertEqual(pickedDate.asFormattedString(), viewController.buttonDateTimeFrom.titleLabel?.text)
        XCTAssertEqual(pickedDate.asFormattedString(), viewController.buttonDateTimeUntil.titleLabel?.text)
    }
    
    func testPickedUntilBeforeBeforeChangedBefore() {
        let pickedDate = Date.makeDateFromComponents(day: 6, month: 12, year: 2016)
        
        viewController.confirmedPick(PickableDate(title: "", field: .until), date: pickedDate)
        
        XCTAssertEqual(pickedDate.asFormattedString(), viewController.buttonDateTimeUntil.titleLabel?.text)
        XCTAssertEqual(pickedDate.asFormattedString(), viewController.buttonDateTimeFrom.titleLabel?.text)
    }
    
    
    func testAddTimeLogButtonCallsPersistence() {
        sendActionAddButtonPressed()
        
        XCTAssertNotNil(fakeTimeLogEntityPersistence.persistedTimeLogData)
    }
    
    func testAddTimeLogButtonPersistsWithChangedCkStatus() {
        
        let changedActivity = "Another activity"
        
        viewController.textEditActivity.text = changedActivity
        sendActionAddButtonPressed()
        
        XCTAssertEqual(fakeTimeLogEntityPersistence.persistedTimeLogData!.Activity, changedActivity)
    }
    
    
    private func sendActionAddButtonPressed() {
        UIApplication.shared.sendAction(
            viewController.navButtonSave.action!,
            to: viewController.navButtonSave.target,
            from: self,
            for: nil)
    }
}


class FakeTimeLogEditDelegate: TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        
    }
}

class FakeTimeLogEntityPersistence: TimeLogEntityPersistence {
    
    var persistedTimeLogData: TimeLogData?
    
    func persist(_ timeLogData: TimeLogData) -> Result {
        persistedTimeLogData = timeLogData
        return Result.Success()
    }
}
