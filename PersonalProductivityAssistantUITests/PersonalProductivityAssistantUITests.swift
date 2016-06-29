//
//  PersonalProductivityAssistantUITests.swift
//  PersonalProductivityAssistantUITests
//
//  Created by Stefan Mehnert on 17/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest

extension XCUIElement {
    func getValueAsStringSafe() -> String {
        guard let valueAsString = self.value as? String else {
            return ""
        }
        return valueAsString
    }
}

extension NSDate {
    static func getCurrentDateTimeAsFormattedString(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(NSDate())
    }
}

class PersonalProductivityAssistantUITests: XCTestCase {
        
    var app = XCUIApplication()
    var toolbarAddActivityButton: XCUIElement?
    var activityInputField: XCUIElement?
    var datePickerFrom: XCUIElement?

    var tableView: XCUIElement?
    let tablesQuery = XCUIApplication().tables
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        activityInputField = app.textFields["textEditActivity"]
        toolbarAddActivityButton = app.toolbars.buttons["Log Time"]
        datePickerFrom = app.datePickers.elementBoundByIndex(0)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCanAddAndDeleteActivityFromTable() {
       let activityName = getActivityNameWithDateTime()
        
        // Open the add time log view
        waitForElementToAppear(toolbarAddActivityButton!)
        toolbarAddActivityButton!.tap()
        toolbarAddActivityButton!.tap()
        
        // Type new time log informations
        waitForElementToAppear(activityInputField!)
        doTypeInActivityName(activityName)
        setDatePickerValues(datePickerFrom!, monthAndDay: "Aug 1", hour: "12", minute: "20", amPm: "AM")
        
        // Press add button
        app.navigationBars["Title"].buttons["add"].tap()
        
        // Verify element has been added
        XCTAssert(getTableStaticTextElement(activityName).exists)
        
        // Swipe up until the new element ist visible
        doSwipeUpUntilTableStaticTextIsHittable(activityName)
        // Swipe left and push delete button
        doDeleteTableRow(activityName)
        
        // Verify the element has been deleted
        XCTAssert(!getTableStaticTextElement(activityName).exists)
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
    
    func doTypeInActivityName(activityName: String) {
        XCTAssert(activityInputField!.exists)
        activityInputField!.tap()
        activityInputField!.tap()
        activityInputField!.typeText(activityName)
    }
    
    func doSwipeUpUntilTableStaticTextIsHittable(name: String) {
        while(!tablesQuery.staticTexts[name].hittable) {
            app.swipeUp()
        }
    }
    
    func doDeleteTableRow(name: String) {
        tablesQuery.staticTexts[name].tap()
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
