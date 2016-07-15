//
//  HashtagAutoCompleteAssistant_isAutocompletePossible_Tests.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant

class HashtagAutoCompleteAssistant_isAutocompletePossible_Tests : XCTestCase {
    
    func testInitialString_saysNo() {
        XCTAssertFalse(forInput(""))
    }
    
    
    func forInput(inputString: String) -> Bool {
        return HashtagAutoCompleteAssistant().isAutoCompletePossible(forInputString: inputString)
    }
}