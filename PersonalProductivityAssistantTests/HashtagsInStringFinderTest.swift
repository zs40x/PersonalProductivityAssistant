//
//  HashtagsInStringFinder.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 03/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant


class HashtagsInStringFinderTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func excerciseHashtagsInString(searchString: String) -> [String] {
        return HashtagsInStringFinder(searchString: searchString).hashtagsInString()
    }

    
    func testNoKeywordsReturnEmptyArray() {
        XCTAssertEqual([String](), excerciseHashtagsInString(""))
    }
}
