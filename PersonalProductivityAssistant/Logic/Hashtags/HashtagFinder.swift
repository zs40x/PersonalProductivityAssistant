//
//  HashtagFinder.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 03/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class HashtagFinder {
    
    var hashtagRepository: HashtagRepository
    
    init(hashtagRepository: HashtagRepository) {
        self.hashtagRepository = hashtagRepository
    }
    
    func resolveHashtags(stringWithHastags string: String) -> ResultValue<[Hashtag]> {
        
        return ResultValue.Success(
                string.hashtags.map {
                    newOrExistingInstanceFromRepository($0)
                }
            )
    }
    
    func newOrExistingInstanceFromRepository(_ hashtagName: String) -> Hashtag {
        
        let allHashtags = self.hashtagRepository.getAll().value!
        
        if let existingHashtag = allHashtags.filter({ $0.name == hashtagName }).first {
            return existingHashtag
        }
        
        return hashtagRepository.addNew(withName: hashtagName).value!
    }
}
