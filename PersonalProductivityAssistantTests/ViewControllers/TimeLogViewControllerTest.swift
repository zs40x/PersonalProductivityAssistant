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
    
    let timeLogData = TimeLogData(Activity: "anActivity")
    let fakeTimeLogEditDelegate = FakeTimeLogEditDelegate()
    
    var viewController = TimeLogViewController()
    
    override func setUp() {
        super.setUp()
        
        viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "TimeLogView") as! TimeLogViewController
        
        viewController.timeLogDataToEdit = timeLogData
        viewController.timeLogEditDelegate = fakeTimeLogEditDelegate
        
        UIApplication.shared.keyWindow!.rootViewController = viewController
        let _ = viewController.view
    }
    
    
    func testDisplaysActivity() {
        
        XCTAssertNotNil(viewController.textEditActivity?.text)
        XCTAssertEqual(timeLogData.Activity, viewController.textEditActivity.text)
    }
}


class FakeTimeLogEditDelegate : TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        
    }
}
