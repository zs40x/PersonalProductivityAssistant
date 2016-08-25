//
//  HashtagFinderTest.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 09/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
@testable import PersonalProductivityAssistant

class HashtagFinderTest: XCTestCaseCoreDataInMemory {
    
    var hashtagRepository: HashtagRepository!
    
    override func setUp() {
        super.setUp()
        
        hashtagRepository = HashtagRepository()
        hashtagRepository.replaceManagedObjectContext(managedObjectContext)
    }
    
    
    func testThatStoreIsSetUp() {
        XCTAssertNotNil(store, "no persistent store")
    }
    
    func testNoHashtags() {
        excersiseHashtagFinder(forString: "test")
        
        XCTAssertEqual(hashtagRepository.getAll().value!.count, 0)
    }
    
    func testAddsANewHashtag() {
        let foundHashtags = excersiseHashtagFinder(forString: "#test")
        let allHashtagsInDb = hashtagRepository.getAll().value!
        
        XCTAssertEqual(foundHashtags.count, 1)
        XCTAssertEqual(foundHashtags.first!.name, "#test")
        
        XCTAssertEqual(allHashtagsInDb.count, 1)
        XCTAssertEqual(foundHashtags.first, allHashtagsInDb.first)
    }
    
    func testPersistsNewHashtagsInDb() {
        excersiseHashtagFinder(forString: "#test_1")
        excersiseHashtagFinder(forString: "#test_2")
        
        XCTAssertTrue(existsHashtagWithNameInDatabase("#test_1"))
        XCTAssertTrue(existsHashtagWithNameInDatabase("#test_2"))
    }
    
    func testIgnoresDuplicates() {
        let firstResult = excersiseHashtagFinder(forString: "#test_xy")
        let secondResult = excersiseHashtagFinder(forString: "#test_xy")
        
        XCTAssertEqual(firstResult, secondResult)
        XCTAssertEqual(hashtagRepository.getAll().value!.count, 1)
    }
    
    func testAddsMultiple() {
        excersiseHashtagFinder(forString: "#this is a #test")
        
        XCTAssertTrue(existsHashtagWithNameInDatabase("#this"))
        XCTAssertTrue(existsHashtagWithNameInDatabase("#test"))
        XCTAssertEqual(hashtagRepository.getAll().value!.count, 2)
    }
    
    
    func excersiseHashtagFinder(forString string: String) -> [Hashtag] {
        
        let hashtagFinderResult =  HashtagFinder(
                hashtagRepository: hashtagRepository).resolveHashtags(stringWithHastags: string)
        
        XCTAssertTrue(hashtagFinderResult.isSucessful, "Hashtag Finder Result must be successful")
        
        return hashtagFinderResult.value!
    }
    
    func existsHashtagWithNameInDatabase(_ name: String) -> Bool {
        return ( hashtagRepository.getAll().value!.filter({ $0.name == name }).count > 0 )
    }
}
