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
    
    func testNoHashtags() {
        let result = excersiseHashtagFinder(forString: "test", existingHashtags: [String]())
        
        XCTAssertEqual(result.addedHashtags, [String]())
        XCTAssertEqual(result.storedHashtags, [String]())
    }
    
    func testExistingHashtag() {
        let result = excersiseHashtagFinder(forString: "#test", existingHashtags: ["#test"])
        
        XCTAssertEqual(result.addedHashtags, [String]())
        XCTAssertEqual(result.storedHashtags, ["#test"])
    }
    
    
    func excersiseHashtagFinder(forString string: String, existingHashtags: [String]) -> (addedHashtags: [String], storedHashtags: [String]) {
        let fakeHashtagRepository = makeFakeHashtagRepository(existingHashtags)
        
        let hashtagFinderResult =  HashtagFinder(
            hashtagRepository: fakeHashtagRepository).resolveHashtags(stringWithHastags: string)
        
        XCTAssertTrue(hashtagFinderResult.isSucessful, "Hashtag Finder Result must be successful")

        return (addedHashtags: fakeHashtagRepository.Added, storedHashtags: fakeHashtagRepository.Stored)
    }
    
    func makeFakeHashtagRepository(existingHashtags: [String]) -> FakeHashtagRepository {
        return FakeHashtagRepository(existingHashtags: existingHashtags)
    }
}

class FakeHashtagRepository : HashtagRepository {
    
    private var storedHashtags: [String]
    private var addedHashtags = [String]()
    
    init(existingHashtags: [String]) {
        self.storedHashtags = existingHashtags
    }
    
    var Added: [String] {
        get {
            return addedHashtags;
        }
    }
    var Stored: [String] {
        get {
            return storedHashtags
        }
    }
    
    
    func getAll() -> ResultValue<[Hashtag]> {
        return ResultValue.Success(knownHashtagsFromStringArray())
    }
    
    func addNew(withName name: String) -> ResultValue<Hashtag> {
        self.addedHashtags.append(name)
        self.storedHashtags.append(name)
        
        return ResultValue.Success(makeHashtag(withName: name))
    }
    
    func knownHashtagsFromStringArray() -> [Hashtag] {
        var hashtags = [Hashtag]()
        
        for hashtagName in self.storedHashtags {
            hashtags.append(makeHashtag(withName: hashtagName))
        }
        
        return hashtags
    }
    
    func makeHashtag(withName name: String) -> Hashtag {
        let newHashtag = Hashtag()
        newHashtag.name = name
        return newHashtag
    }
}