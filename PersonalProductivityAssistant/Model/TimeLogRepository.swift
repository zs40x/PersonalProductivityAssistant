//
//  TimeLogRepository.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import CoreData

open class TimeLogRepository {
    

    fileprivate var model = PPAModel.New()
    

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
    
    func forMonthOf(_ date: Date) -> ResultValue<[TimeLog]> {
        
        do {
            let firstOfMonthDate = date.firstDayOfMonth()
            let firstOfNextMonthDate = firstOfMonthDate.addMonthCount(1)
            
            print("TimeLogRepository.forMonthOf() ->  >= \(firstOfMonthDate) && < \(firstOfNextMonthDate)")
            
            let allTimeLogs =
                try model.TimeLogs.getTimeLogsForDateRange(firstOfMonthDate, dateUntil: firstOfNextMonthDate)
            
            return ResultValue.Success(allTimeLogs)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }

    
    func addNew(_ timeLogData: TimeLogData) -> ResultValue<TimeLog> {
  
        do {
            let newTimeLog = model.TimeLogs.createTimeLog(timeLogData)
            newTimeLog.updateHashtags()
            
            try model.save()
            
            return ResultValue.Success(newTimeLog)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }
    
    func delete(_ timeLogToDelete: TimeLog) -> Result {
        
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
