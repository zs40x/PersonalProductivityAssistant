//
//  HashtagFinderTest.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 09/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant

class HashtagFinderTest: XCTestCase {
    
    
    
    func excersiseHastagFinder(string: String) -> ResultValue<[Hashtag]> {
        return HashtagFinder(hashtagRepository: HashtagRepository()).resolveHashtags(stringWithHastags: string)
    }
}
