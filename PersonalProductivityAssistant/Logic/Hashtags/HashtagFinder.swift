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
        
        
        
        return ResultValue.Success([Hashtag]())
    }
}


internal class HashtagsInStringFinder {
    
    let searchString: String
    
    init(searchString: String) {
        self.searchString = searchString
    }
    
    
    func hashtagsInString() -> [String] {
        var foundHashtags = [String]()
        
        let words = searchString.characters.split(" ")
    
        for word in words {
            let wordAsString = String(word)
            
            if wordAsString.hasPrefix("#") {
               foundHashtags.append(wordAsString)
            }
        }
        
        return foundHashtags
    }
}