//
//  ReportingDiagramSourceFreeVsUsedTime.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 29/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class ChartSourceFreeVsUsedTime : ChartDataValueProvider {
    
    let timeLogRepository = TimeLogRepository();
    
    
    func getChartData() -> ChartDataValues {
        let usedTime = getUsedTimeAmount()
        let freeTime = 24.0 - usedTime
        
        return ChartDataValues(
                dataPoints: ["Free Time", "Used Time"],
                values: [freeTime, usedTime]
            );
    }
    
    func getUsedTimeAmount() -> Double {
        var totalHours: Double = 0
        let minutesPerHour = 60.0
        
        let getAllTimeLogsResult = timeLogRepository.getAll()
        
        guard getAllTimeLogsResult.isSucessful else {
            return 0
        }
        
        for timeLog in getAllTimeLogsResult.value! {
            totalHours += Double(timeLog.durationInMinutes()) / minutesPerHour
        }
        
        return totalHours
    }
    
}