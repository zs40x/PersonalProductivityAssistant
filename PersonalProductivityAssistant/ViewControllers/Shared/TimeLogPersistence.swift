//
//  TimeLogPersistence.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 23/08/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

protocol TimeLogEntityPersistence {
    func persist(_ timeLogData: TimeLogData) -> Result;
}

class AddNewTimeLogEntity : TimeLogEntityPersistence {
    
    var timeLogRepository =  TimeLogRepository()
    
    func persist(_ timeLogData: TimeLogData) -> Result {
        
        let newTimeLogResult = timeLogRepository.addNew(timeLogData)
        
        if !newTimeLogResult.isSucessful {
            return Result.Failure("Error adding a new time log \(newTimeLogResult.errorMessage)")
        }
        
        return Result.Success()
    }
}

class UpdateTimeLogEntity : TimeLogEntityPersistence {
    
    weak var timeLog: TimeLog?
    
    init(timeLog: TimeLog) {
        self.timeLog = timeLog
    }
    
    func persist(_ timeLogData: TimeLogData) -> Result {
        
        guard let timeLog = timeLog else {
            return Result.Failure("TimeLog was nil")
        }
        
        timeLog.updateFromTimeLogData(timeLogData)
        
        let saveChangesResult = TimeLogRepository().save()
        
        if !saveChangesResult.isSucessful {
            return Result.Failure("Error saving timeLog changes \(saveChangesResult.errorMessage)")
        }
        
        return Result.Success()
    }
}
