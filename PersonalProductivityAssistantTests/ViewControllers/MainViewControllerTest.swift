//
//  MainViewControllerTest.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 28/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant


class MainViewControllerTest: XCTestCaseCoreDataInMemory {
    
    var viewController = MainViewController()
    
    
    override func setUp() {
        super.setUp()
        
        viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "MainView") as! MainViewController
        
        let _ = viewController.view
    }
}
