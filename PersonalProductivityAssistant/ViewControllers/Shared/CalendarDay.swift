//
//  CalendarDay.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 28/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import JTCalendar

enum CalendarDayClassification {
    case otherMonth
    case timeLog
    case today
    case tapped
}

class CalendarDay {
    
    private let dayView: JTCalendarDayView
    
    private init(calendarViewDay: JTCalendarDayView) {
        self.dayView = calendarViewDay
    }
    
    
    func configure(classification: CalendarDayClassification) {
        
        resetToDefaults()
        
        switch classification {
            
        case .otherMonth:
            dayView.textLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            
        case .timeLog:
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)

        case .today:
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            
        case .tapped:
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 0.8309050798, green: 0.9848287702, blue: 0.4713753462, alpha: 1)
        }

    }
    
    private func resetToDefaults() {

        dayView.isHidden = false
        dayView.dotView.isHidden = true
        dayView.circleView.isHidden = true
        dayView.textLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
