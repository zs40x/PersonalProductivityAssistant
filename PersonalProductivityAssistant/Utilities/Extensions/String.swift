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
}