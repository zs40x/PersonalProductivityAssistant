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
    
    let selectedDate = Date.makeDateFromComponents(day: 2015, month: 07, year: 27)
    
    let fakeDateTimePickDelegate = FakeDateTimePickDelegate()
    var viewController = DateTimePickViewController()
    
    
    override func setUp() {
        super.setUp()
        
        viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "DateTimePickView") as! DateTimePickViewController
        
        viewController.selectedDateTime = selectedDate
        viewController.pickDelegate = fakeDateTimePickDelegate
        
        let _ = viewController.view
    }
    
 
}


class FakeDateTimePickDelegate: DateTimePickDelegate {
    
    func confirmedPick(_ pickedDate: PickableDate, date: Date) {
        
    }
}
