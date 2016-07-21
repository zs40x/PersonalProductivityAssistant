//
//  TimeLog.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TimeLog: NSManagedObject {

    static let EntityName = "TimeLog"
    
    func activityAsAttributedString() -> NSAttributedString {
        let attributedActivity = NSMutableAttributedString(string: self.activity!)
        
        for word in self.activity!.byWords {
            if !word.hasPrefix("#") {
                continue
            }
            
            for hashtagRange in self.activity!.findOccurencesOf(text: word) {
                
                let wordWithoutHashtag = word.characters.dropFirst()
                
                attributedActivity.addAttribute(
                    NSLinkAttributeName, value:"hash:\(wordWithoutHashtag.dropFirst())", range: hashtagRange)
                //attributedActivity.addAttribute(
                //    NSFontAttributeName, value: UIFont.systemFontOfSize(15.0), range: hashtagRange)
                attributedActivity.addAttribute(
                    NSUnderlineStyleAttributeName, value: NSUnderlineStyle.PatternDot.rawValue, range: hashtagRange)
            }
        }
        
        return attributedActivity
    }
    
    func durationInMinutes() -> Int {
        guard let timeFrom = from else {
            return 0
        }
        guard let timeUntil = until else {
            return 0
        }
        
        return Int(timeUntil.timeIntervalSinceDate(timeFrom) / 60)
    }
    
    func asTimeLogData() -> TimeLogData {
        return TimeLogData(Activity: activity!, From: from!, Until: until!)
    }
    
    func updateFromTimeLogData(timeLogData: TimeLogData) {
        self.activity = timeLogData.Activity
        self.from = timeLogData.From
        self.until = timeLogData.Until
        
        self.updateHashtags()
    }
    
    func updateHashtags() {
        let foundHashtags =
            HashtagFinder(hashtagRepository: HashtagRepository())
                .resolveHashtags(stringWithHastags: self.activity!).value!
        
        self.hashtags = NSSet(array: foundHashtags)
    }
}
