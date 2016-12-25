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
    
    func testStringWithoutDash_saysNo() {
        XCTAssertFalse(forInput("test"))
    }
    
    func testFirstCharacterIsADash_saysYes() {
        XCTAssertTrue(forInput("#"))
    }
    
    func testSingleHashtagWork_saysYes() {
        XCTAssertTrue(forInput("#test"))
    }
    
    func testTwoWordsFirstHashtagSecondNone_saysNo() {
        XCTAssertFalse(forInput("#test no"))
    }
    
    func testLastWordIsAHashtagWithTrailingSpace_saysNo() {
        XCTAssertFalse(forInput("word #hastag "))
    }
    
    
    func forInput(_ inputString: String) -> Bool {
        return HashtagAutoCompleteAssistant().isAutoCompletePossible(forInputString: inputString)
    }
}
