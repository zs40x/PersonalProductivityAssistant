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
        
        if lastWord.characters.startsWith(["#"]) {
            return true
        }
        
        return false
    }
}