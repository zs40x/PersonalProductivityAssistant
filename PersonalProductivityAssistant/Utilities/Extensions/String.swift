//
//  String.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension String {
    func findOccurencesOf(text text:String) -> [NSRange] {
        return !text.isEmpty ? try! NSRegularExpression(pattern: text, options: []).matchesInString(self, options: [], range: NSRange(0..<characters.count)).map{ $0.range } : []
    }
    
    var byWords: [String] {
        var wordsInString = [String]()
        
        let words = characters.split{ $0 == " " }.map(String.init)
        for word in words  {
            wordsInString.append(word)
        }
        
        if wordsInString.count == 0 {
            wordsInString.append(self)
        }
        
        return wordsInString
    }
    
    var lastWord: String? {
        return byWords.last
    }
    
    func lastWords(maxWords: Int) -> [String] {
        return Array(byWords.suffix(maxWords))
    }
    
    var uniqueHashtags : [String] {
        get {
            return self.byWords.filter { $0.hasPrefix("#") }
        }
    }
}