//
//  TimeLogRepository.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData

public class TimeLogRepository {
    
    private var model = PPAModel.New()
    
    
    func getManagedObjectContext() -> NSManagedObjectContext {
        return model.managedObjectContext
    }
    
    func getAll() -> ResultValue<[TimeLog]> {
        
        do {
            let allTimeLogs = try model.TimeLogs.getAllTimeLogs()
            return ResultValue.Success(allTimeLogs)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }
    
    func forMonthOf(date: NSDate) -> ResultValue<[TimeLog]> {
        
        do {
            let calendar = NSCalendar.currentCalendar()
            
            let startOfMonthDateComponents = calendar.components([.Year, .Month], fromDate: NSDate())
            let startOfMonthDate = calendar.dateFromComponents(startOfMonthDateComponents)!
            
            let startDateTime =
                calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: startOfMonthDate, options: [])!
            let endDateTime =
                calendar.dateBySettingHour(0, minute: 0, second: 0, ofDate: startOfMonthDate, options: [])!
            
            let endOfMonthDateComponents = NSDateComponents()
            endOfMonthDateComponents.month = 1
            endOfMonthDateComponents.day = 0
            
            let endOfMonthDateTime =
                calendar.dateByAddingComponents(endOfMonthDateComponents, toDate: endDateTime, options: [])!
            
            print("TimeLogRepository.forMonthOf() - Range: \(startDateTime)-\(endOfMonthDateTime)")
            
            
            let allTimeLogs = try model.TimeLogs.getTimeLogsForDateRange(startDateTime, dateUntil: endOfMonthDateTime)
            return ResultValue.Success(allTimeLogs)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }

    
    func addNew(timeLogData: TimeLogData) -> ResultValue<TimeLog> {
  
        do {
            let newTimeLog = model.TimeLogs.createTimeLog(timeLogData)
            newTimeLog.updateHashtags()
            
            try model.save()
            
            return ResultValue.Success(newTimeLog)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }
    
    func delete(timeLogToDelete: TimeLog) -> Result {
        
        do {
            model.TimeLogs.deleteTimeLog(timeLogToDelete)
            try model.save()
            return Result.Success()
        } catch let error as NSError {
            return Result.Failure(error.getDefaultErrorMessage())
        }
    }
    
    func save() -> Result {
        do {
            try model.save()
            return Result.Success()
        } catch let error as NSError {
            return Result.Failure(error.getDefaultErrorMessage())
        }
    }
}