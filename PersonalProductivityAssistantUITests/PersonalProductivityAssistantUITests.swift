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
    var datePickerFrom: XCUIElement?
    var datePickerUntil: XCUIElement?

    var tableView: XCUIElement?
    let tablesQuery = XCUIApplication().tables
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
     
        app.launch()

        activityInputField = app.textFields["textEditActivity"]
        toolbarAddActivityButton = app.toolbars.buttons["Log Time"]
        datePickerFrom = app.datePickers.elementBoundByIndex(0)
        datePickerUntil = app.datePickers.elementBoundByIndex(1)
    }
    
    override func tearDown() {
        super.tearDown()
        
        app.terminate()
    }
    
    func testCanAddAndEditAndDeleteActivityFromTable() {
        //
        // Add
        //
        // Open the add time log view
        waitForElementToAppear(toolbarAddActivityButton!)
        toolbarAddActivityButton!.tap()
        toolbarAddActivityButton!.tap()
        
        // Type new time log informations
        waitForElementToAppear(activityInputField!)
        let initialActivityName = getActivityNameWithDateTime()
        typeActivityName(initialActivityName)
        setDatePickerValues(datePickerFrom!, monthAndDay: "Aug 1", hour: "10", minute: "30", amPm: "AM")
        setDatePickerValues(datePickerUntil!, monthAndDay: "Aug 1", hour: "11", minute: "15", amPm: "AM")
        
        // Press add button
        app.navigationBars["Title"].buttons["add"].tap()
        
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
        
        // Press add button
        app.navigationBars["Title"].buttons["add"].tap()
        
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
    
    private func waitForElementToAppear(element: XCUIElement,
                                        file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectationForPredicate(existsPredicate,
                                evaluatedWithObject: element, handler: nil)
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after 5 seconds."
                self.recordFailureWithDescription(message,
                                                  inFile: file, atLine: line, expected: true)
            }
        }
    }
    
    func setDatePickerValues(datePicker: XCUIElement, monthAndDay: String, hour: String, minute: String, amPm: String) {
        datePicker.pickerWheels.elementBoundByIndex(0).adjustToPickerWheelValue(monthAndDay)
        datePicker.pickerWheels.elementBoundByIndex(1).adjustToPickerWheelValue(hour)
        datePicker.pickerWheels.elementBoundByIndex(2).adjustToPickerWheelValue(minute)
        datePicker.pickerWheels.elementBoundByIndex(3).adjustToPickerWheelValue(amPm)
    }
    
    func typeActivityName(activityName: String) {
        XCTAssert(activityInputField!.exists)
        activityInputField!.tap()
        activityInputField!.tap()
        activityInputField!.typeText(activityName)
    }

    func clearAndTypeActivityName(activityName: String) {
        XCTAssert(activityInputField!.exists)
        activityInputField!.tap()
        activityInputField!.tap()
        app.menuItems["Select All"].tap()
        activityInputField!.typeText(activityName)
    }
    
    func doSwipeUpUntilTableStaticTextIsHittable(name: String) {
        while(!tablesQuery.staticTexts[name].hittable) {
            app.swipeUp()
        }
    }
    
    func doDeleteTableRow(name: String) {
        tablesQuery.staticTexts[name].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
    }
    
    func getTableStaticTextElement(name: String) -> XCUIElement {
        return tablesQuery.staticTexts[name]
    }
    
    func getActivityNameWithDateTime() -> String {
        return "A " + NSDate.getCurrentDateTimeAsFormattedString("dd.MM.YYYY HH:mm:ss")
    }
}
