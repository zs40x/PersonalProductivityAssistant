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
        
        let viewController = makeTestInstance()
        
    }
    
    private func makeTestInstance() -> TimeLogViewController {
        
        let viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "TimeLogViewController") as! TimeLogViewController
        
        viewController.timeLogEditDelegate = FakeTimeLogEditDelegate()
        
        return viewController
    }
}


class FakeTimeLogEditDelegate : TimeLogEditDelegate {
    
    func timeLogModified(_ withStartDate: Date) {
        
    }
}
