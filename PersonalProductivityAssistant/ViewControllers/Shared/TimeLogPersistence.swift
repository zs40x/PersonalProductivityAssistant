//
//  TimeLogPersistence.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 23/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol TimeLogEntityPersistence {
    func persist(timeLogData: TimeLogData) -> Result;
}

class AddNewTimeLogEntity : TimeLogEntityPersistence {
    
    var timeLogRepository =  TimeLogRepository()
    
    func persist(timeLogData: TimeLogData) -> Result {
        
        let newTimeLogResult = timeLogRepository.addNew(timeLogData)
        
        if !newTimeLogResult.isSucessful {
            return Result.Failure("Error adding a new time log \(newTimeLogResult.errorMessage)")
        }
        
        return Result.Success()
    }
}

class UpdateTimeLogEntity : TimeLogEntityPersistence {
    
    var timeLog: TimeLog
    var timeLogRepository = TimeLogRepository()
    
    init(timeLog: TimeLog) {
        self.timeLog = timeLog
    }
    
    func persist(timeLogData: TimeLogData) -> Result {
        
        timeLog.updateFromTimeLogData(timeLogData)
        
        let saveChangesResult = timeLogRepository.save()
        
        if !saveChangesResult.isSucessful {
            return Result.Failure("Error saving timeLog changes \(saveChangesResult.errorMessage)")
        }
        
        return Result.Success()
    }
}