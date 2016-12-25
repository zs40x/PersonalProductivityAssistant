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
    
    func testDisplaysActivity() {
        
        let timeLogData = TimeLogData(Activity: "anActivity")
    
        let viewController = makeTestInstance(withTimeLogData: timeLogData)
        viewController.timeLogDataToEdit = timeLogData
        
        UIApplication.shared.keyWindow!.rootViewController = viewController
        let _ = viewController.view
        
        XCTAssertNotNil(viewController.textEditActivity?.text)
        XCTAssertEqual(timeLogData.Activity, viewController.textEditActivity.text)
    }
    
    private func makeTestInstance(withTimeLogData: TimeLogData?) -> TimeLogViewController {
        
        let viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "TimeLogView") as! TimeLogViewController
        
        viewController.timeLogEditDelegate = FakeTimeLogEditDelegate()
        
        return viewController
    }
}


class FakeTimeLogEditDelegate : TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        
    }
}
