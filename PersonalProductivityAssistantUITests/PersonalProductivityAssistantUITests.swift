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
    var activityInputField: XCUIElement?
    var addActivityButton: XCUIElement?
    var tableView: XCUIElement?
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        activityInputField = app.textFields["textEditActivity"]
        addActivityButton = app.buttons["buttonLogActivity"]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddAnActitivty() {
        let activityName = getActivityNameWithDateTime()
        
        doTypeInActivityName(activityName)
        
        XCTAssertEqual(activityName, activityInputField!.getValueAsStringSafe())
        
        doTapAddActivityButton()
        
        // Make sure a activity with the name is in the list
        XCTAssert(app.tables.cells.staticTexts[activityName].exists)
    }
    
    func testCanDeleteActivityFromTable() {
       let activityName = getActivityNameWithDateTime()
        
        doTypeInActivityName(activityName)
        doTapAddActivityButton()
        
        // new Activity must exist
        XCTAssert(app.tables.cells.staticTexts[activityName].exists)
        
        let newActivityCell = app.tables.staticTexts[activityName]
        XCTAssert(newActivityCell.exists)
        
        /*let hittable = NSPredicate(format: "hittable == 1")
        expectationForPredicate(hittable, evaluatedWithObject: newActivityCell, handler: nil)
        waitForExpectationsWithTimeout(5, handler: nil)
        
        newActivityCell.tap()
        
        let cellDeleteButton = app.tables.buttons["Delete"]
        XCTAssert(cellDeleteButton.exists)
        cellDeleteButton.tap()*/
        
        
        let tablesQuery = XCUIApplication().tables
        
        while(!tablesQuery.staticTexts[activityName].hittable) {
            app.swipeUp()
        }
        
        
        tablesQuery.staticTexts[activityName].tap()
        tablesQuery.staticTexts[activityName].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        
        // Activity must be removed
        XCTAssert(!app.tables.cells.staticTexts[activityName].exists)
    }
    
    
    func doTypeInActivityName(activityName: String) {
        XCTAssert(activityInputField!.exists)
        activityInputField!.tap()
        activityInputField!.typeText(activityName)
    }
    
    func doTapAddActivityButton() {
        XCTAssert(addActivityButton!.exists)
        addActivityButton!.tap()
    }
    
    func getActivityNameWithDateTime() -> String {
        return "A " + NSDate.getCurrentDateTimeAsFormattedString("dd.MM.YYYY HH:mm:ss")
    }
}
