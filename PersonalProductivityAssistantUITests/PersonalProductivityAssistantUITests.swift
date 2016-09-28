//
//  PersonalProductivityAssistantUITests.swift
//  PersonalProductivityAssistantUITests
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest

class PersonalProductivityAssistantUITests: XCTestCase {
        
    var app = XCUIApplication()
    var toolbarAddActivityButton: XCUIElement?
    var activityInputField: XCUIElement?
    var datePicker: XCUIElement?
    var buttonPickDateTimeFrom: XCUIElement?
    var buttonPickDateTimeUntil: XCUIElement?
    var labelActivity: XCUIElement?
    var setDateTimeFromButton: XCUIElement?
    var setDateTimeUntilButton: XCUIElement?
    var timeLogSaveButton: XCUIElement?
    var calendarViewFirstDay: XCUIElement?
    
    var tableView: XCUIElement?
    let tablesQuery = XCUIApplication().tables
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
     
        app.launch()

        activityInputField = app.textFields["textEditActivity"]
        toolbarAddActivityButton = app.toolbars.buttons["Log Time"]
        datePicker = app.datePickers.element(boundBy: 0)
        buttonPickDateTimeFrom = app.buttons["dateTimeFrom"]
        buttonPickDateTimeUntil = app.buttons["dateTimeUntil"]
        labelActivity = app.staticTexts.element(matching: .any, identifier: "Activity")
        setDateTimeFromButton = app.navigationBars["From"].buttons["Set"]
        setDateTimeUntilButton = app.navigationBars["Until"].buttons["Set"]
        timeLogSaveButton = app.navigationBars["Time Log"].buttons["Save"]
        calendarViewFirstDay = app.collectionViews.staticTexts["1"]
    }
    
    override func tearDown() {
        super.tearDown()
        
        app.terminate()
    }
    
    func testCanAddAndEditAndDeleteActivityFromTable() {
        //
        // Swipe calender to August
        //
        calendarViewFirstDay?.swipeLeft()
        
        //
        // Add
        //
        // Open the add time log view
        waitForElementToAppear(toolbarAddActivityButton!)
        toolbarAddActivityButton!.doubleTap()
        
        // Type new time log informations
        waitForElementToAppear(activityInputField!)
        let initialActivityName = getActivityNameWithDateTime()
        typeActivityName(initialActivityName)
        labelActivity?.tap()
        
        buttonPickDateTimeFrom?.tap()
        setDatePickerValues(monthAndDay: "Aug 1", hour: "10", minute: "30", amPm: "AM")
        setDateTimeFromButton?.tap()
        
        buttonPickDateTimeUntil?.tap()
        setDatePickerValues(monthAndDay: "Aug 1", hour: "11", minute: "15", amPm: "AM")
        setDateTimeUntilButton?.tap()
        
        timeLogSaveButton?.tap()
        
        // Verify element has been added
        XCTAssert(getTableStaticTextElement(initialActivityName).exists)
        
        //
        // Edit
        //
        // tap the actiity to open the add/edit segue
        getTableStaticTextElement(initialActivityName).tap()
        
        let changedActivityName = "\(getActivityNameWithDateTime()) #test"
        waitForElementToAppear(activityInputField!)
        clearAndTypeActivityName(changedActivityName)
        
        timeLogSaveButton?.tap()
        
        // Verify element has been modifed
        XCTAssert(getTableStaticTextElement(changedActivityName).exists)
        
        //
        // Delete
        //
        // Swipe up until the new element ist visible
        doSwipeUpUntilTableStaticTextIsHittable(changedActivityName)
        // Swipe left and push delete button
        doDeleteTableRow(changedActivityName)
        
        // Verify the element has been deleted
        XCTAssert(!getTableStaticTextElement(changedActivityName).exists)
    }
    
    func setDatePickerValues(monthAndDay: String, hour: String, minute: String, amPm: String) {
        self.datePicker!.pickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: monthAndDay)
        self.datePicker!.pickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: hour)
        self.datePicker!.pickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: minute)
        self.datePicker!.pickerWheels.element(boundBy: 3).adjust(toPickerWheelValue: amPm)
    }
    
    func typeActivityName(_ activityName: String) {
        XCTAssert(activityInputField!.exists)
        activityInputField!.tap()
        activityInputField!.tap()
        activityInputField!.typeText(activityName)
    }

    func clearAndTypeActivityName(_ activityName: String) {
        XCTAssert(activityInputField!.exists)
        activityInputField!.tap()
        activityInputField!.tap()
        app.menuItems["Select All"].tap()
        activityInputField!.typeText(activityName)
    }
    
    func doSwipeUpUntilTableStaticTextIsHittable(_ name: String) {
        while(!tablesQuery.textViews[name].isHittable) {
            app.swipeUp()
        }
    }
    
    func doDeleteTableRow(_ name: String) {
        tablesQuery.textViews[name].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
    }
    
    func getTableStaticTextElement(_ name: String) -> XCUIElement {
        return tablesQuery.textViews[name]
    }
    
    func getActivityNameWithDateTime() -> String {
        return "A " + Date.getCurrentDateTimeAsFormattedString()
    }
}
