//
//  CalendarDayView.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 27/12/2016.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import JTCalendar

class CalendarDayView {
    
    unowned var dayView: JTCalendarDayView
    var timeLogs: [TimeLog]
    var tappedDay: Date?
    var dateHelper = JTDateHelper()
    
    
    init(_ dayView: JTCalendarDayView, timeLogs: [TimeLog], tappedDay: Date?) {
        self.dayView = dayView
        self.timeLogs = timeLogs
        self.tappedDay = tappedDay
    }
    
    func configure() {
        
        resetToDefaults()
        
        if isDayFromOtherMonth() {
            dayView.textLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            return
        }
        
        if timeLogsForDayAvailable() {
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        }
        
        if isToday() {
            dayView.circleView.isHidden = false
            dayView.circleView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
            dayView.dotView.isHidden = false
            dayView.dotView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        if wasTapped() {
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
    
    private func isDayFromOtherMonth() -> Bool {
        
        return dayView.isFromAnotherMonth
    }
    
    private func timeLogsForDayAvailable() -> Bool {
        
        return timeLogs.filter({ dateHelper.date($0.from, isTheSameDayThan: dayView.date) }).first != nil
    }
    
    private func isToday() -> Bool {
        
        return dateHelper.date(Date(), isTheSameDayThan: dayView.date)
    }
    
    private func wasTapped() -> Bool {
        
        guard let tappedDay = tappedDay else { return false }
        
        return dateHelper.date(tappedDay, isTheSameDayThan: dayView.date)
    }
}
