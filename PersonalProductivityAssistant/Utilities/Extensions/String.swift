//
//  String.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 12/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

extension String {
    
    public func findOccurencesOf(text text:String) -> [NSRange] {
        
        guard !text.isEmpty else { return [] }
        
        return
            try! NSRegularExpression(pattern: text, options: [])
                    .matchesInString(self, options: [], range: NSRange(0..<characters.count))
                    .map{ $0.range }
    }
    
    public var byWords: [String] {
       
        let wordsInString =
            characters.split{ $0 == " " }.map(String.init)
        
        return wordsInString.count > 0 ? wordsInString : []
    }
    
    public var lastWord: String? {
        return byWords.last
    }
    
    public func lastWords(maxWords: Int) -> [String] {
        return [String](byWords.suffix(maxWords))
    }
    
    public var hashtags : [String] {
        get {
            return self.byWords.filter { $0.hasPrefix("#") }
        }
    }
}