//
//  TimeLogRepository.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 18/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

public class TimeLogRepository {
    
    private var model = PPAModel.New()
    
    
    func getAll() -> ResultValue<[TimeLog]> {
        
        do {
            let allTimeLogs = try model.TimeLogs.getAllTimeLogs()
            return ResultValue.Success(allTimeLogs)
        } catch let error as NSError {
            return ResultValue.Failure(error.getDefaultErrorMessage())
        }
    }
    
    func addNew(timeLogData: TimeLogData) -> ResultValue<TimeLog> {
  
        do {
            let newTimeLog = model.TimeLogs.createTimeLog(timeLogData)
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