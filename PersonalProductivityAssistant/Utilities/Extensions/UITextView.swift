//
//  UITextView.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 22/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

extension UITextView {
    
    func setTextWithHashtagLinks(text: String) {
        
        let attributedText = NSMutableAttributedString(string: text)
        
        for word in text.byWords {
            if !word.hasPrefix("#") {
                continue
            }
            
            for hashtagRange in text.findOccurencesOf(text: word) {
                
                let wordWithoutHashtag = word.characters.dropFirst()
                
                attributedText.addAttribute(
                    NSLinkAttributeName, value:"hash:\(wordWithoutHashtag.dropFirst())", range: hashtagRange)
            }
        }
        
        attributedText.addAttribute(
            NSFontAttributeName, value: UIFont.systemFontOfSize(16.0), range: NSRange(location: 0, length: attributedText.string.characters.count))
        
        self.attributedText = attributedText
    }
}