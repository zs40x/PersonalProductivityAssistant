//
//  HashtagAutoCompleteAssistant_appendHashtag.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant

class HashtagAutoCompleteAssistant_appendHashtag: XCTestCase {
    
    let hashtagToAppend = "#hashtag"
    
    
    func testAppendToEmptyString() {
        XCTAssertEqual(appendTo(""), "\(hashtagToAppend) ")
    }
    
    func testAppendToWordWithTrailingSpace() {
        XCTAssertEqual(appendTo("word "), "word \(hashtagToAppend) ")
    }
    
    func testReplacesTrailingDash() {
        XCTAssertEqual(appendTo("word #"), "word \(hashtagToAppend) ")
    }
    
    
    func appendTo(string: String) -> String {
        return HashtagAutoCompleteAssistant()
            .appendHastag(withName: hashtagToAppend, to: string)
    }
}
