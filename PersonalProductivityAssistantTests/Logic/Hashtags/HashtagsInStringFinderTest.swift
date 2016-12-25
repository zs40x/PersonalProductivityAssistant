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

    func excerciseHashtagsInString(_ searchString: String) -> [String] {
        return searchString.hashtags
    }

    
    func testNoKeywordsReturnEmptyArray() {
        XCTAssertEqual([String](), excerciseHashtagsInString(""))
    }
    
    func testNonHashtagWordReturnsEmptyArray() {
        XCTAssertEqual([String](), excerciseHashtagsInString("test"))
    }
    
    func testSingleHashtagReturnsAnArrayWithHashtag() {
        XCTAssertEqual(["#test"], excerciseHashtagsInString("#test"))
    }
    
    func testHashtagAndWorkRetunsArrayWithOnlyTheHashtag() {
        XCTAssertEqual(["#thehashtag"], excerciseHashtagsInString("#thehashtag word"))
    }
    
    func testToHashtagsReturnsanArrayWithBoth() {
        XCTAssertEqual(["#hashtag1", "#hashtag2"], excerciseHashtagsInString("#hashtag1 #hashtag2"))
    }
    
    func testHashtagsWithOtherWordsReturnsOnlyHashtags() {
        XCTAssertEqual(["#ht1", "#ht2"], excerciseHashtagsInString("foo #ht1 bar #ht2 nope"))
    }
}
