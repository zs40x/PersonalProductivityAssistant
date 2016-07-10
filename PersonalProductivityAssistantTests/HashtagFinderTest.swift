//
//  HashtagFinderTest.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 09/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import XCTest
import CoreData
@testable import PersonalProductivityAssistant

class HashtagFinderTest: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    var hashtagRepository: HashtagRepository!
    
    override func setUp() {
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        do {
            store = try storeCoordinator.addPersistentStoreWithType(
                            NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        }
        catch let error as NSError {
            XCTFail("could't initialize persistent store \(error)")
        }
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        hashtagRepository = HashtagRepository()
        hashtagRepository.managedObjectContext = managedObjectContext
        
        super.setUp()
    }
    
    override func tearDown() {
        managedObjectContext = nil
        
        do {
            try storeCoordinator.removePersistentStore(store)
        }
        catch let error as NSError {
            XCTFail("couldn't remove persistent store: \(error)")
        }
        
        super.tearDown()
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
        excersiseHashtagFinder(forString: "#test_xy")
        excersiseHashtagFinder(forString: "#test_xy")
        
        XCTAssertEqual(hashtagRepository.getAll().value!.count, 1)
    }
    
    
    func existsHashtagWithNameInDatabase(name: String) -> Bool {
        return ( hashtagRepository.getAll().value!.filter({ $0.name == name }).count > 0 )
    }
    
    func excersiseHashtagFinder(forString string: String, existingHashtags: [String] = [String]()) -> [Hashtag] {
        
        let hashtagFinderResult =  HashtagFinder(
            hashtagRepository: hashtagRepository).resolveHashtags(stringWithHastags: string)
        
        XCTAssertTrue(hashtagFinderResult.isSucessful, "Hashtag Finder Result must be successful")
        
        return hashtagFinderResult.value!
    }
    
}
