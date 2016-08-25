//
//  HashtagAutoCompleteAssistant.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class HashtagAutoCompleteAssistant {
    
    func isAutoCompletePossible(forInputString inputString: String) -> Bool {
        
        guard let lastWord = inputString.lastWord else {
            return false
        }
        
        if lastWord.hasPrefix("#") && !inputString.hasSuffix(" ") {
            return true
        }
        
        return false
    }
    
    func appendHastag(withName hashtag: String, to: String) -> String {
        
        var hashtagToAppend: String = hashtag
        
        if to.hasSuffix("#") {
            hashtagToAppend.remove(at: hashtagToAppend.startIndex)
        }
        
        return "\(to)\(hashtagToAppend) "
    }
}
