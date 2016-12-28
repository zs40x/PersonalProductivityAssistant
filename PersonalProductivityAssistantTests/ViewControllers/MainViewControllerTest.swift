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
    
    private let firstActivityName = "NameOfActivity"
    private let firstRowIndexPath = IndexPath(row: 0, section: 0)
    
    var viewController = MainViewController()
    
    
    override func setUp() {
        super.setUp()
        
        setUpTestData()
        
        viewController =
            UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "MainView") as! MainViewController
        
        let _ = viewController.view
    }
    
    
    func testTimeLogIsDisplayedInTableView() {
        
        let cell = viewController.tableViewActivities.cellForRow(at: firstRowIndexPath)
        
        XCTAssertNotNil(cell)
        
        guard let timeLogCell = cell as? TableViewActivityCell else {
            XCTFail("tableViewCell of unexpected type")
            return
        }
        
        XCTAssertEqual(firstActivityName, timeLogCell.textViewActivity.text)
    }
    
    func testTableViewRecordDateRangeIsDisplayed() {
        
        XCTAssertEqual(Date().asFormattedString(format: Config.shortDateFormat), viewController.displayDateRange.text)
    }
    
    func testTimeLogIsDeleted() {
        
        viewController.tableView(viewController.tableViewActivities, commit: .delete, forRowAt: firstRowIndexPath)
        
        XCTAssertEqual(0, viewController.tableViewActivities.visibleCells.count)
    }

    
    private func setUpTestData() {
        
        let timeLogRepository = TimeLogRepository()
        
        let addResult = timeLogRepository.addNew(TimeLogData(Activity: firstActivityName, From: Date(), Until: Date()))
        
        XCTAssert(addResult.isSucessful)
    }
}
