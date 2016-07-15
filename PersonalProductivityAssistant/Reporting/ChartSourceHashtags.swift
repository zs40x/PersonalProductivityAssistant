//
//  ChartSourceHashtags.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

class ChartSourceHashtags : ChartDataValueProvider {
    
    private let timeLogRepository = TimeLogRepository();
    
    func getChartData() -> ChartDataValues {
        
        var dataPoints = [String]()
        var values = [Double]()
        
        for (hashtag, value) in getHashtagTotals() {
            dataPoints.append(hashtag)
            values.append(value)
        }
        
        return ChartDataValues(
            dataPoints: dataPoints,
            values: values
        );
    }
    
    private func getHashtagTotals() -> [String: Double] {
        var hashtagTotalsDictionary = [String: Double]()
        
        let getAllTimeLogsResult = timeLogRepository.getAll()
        
        guard getAllTimeLogsResult.isSucessful else {
            return hashtagTotalsDictionary
        }
        
        for timeLog in getAllTimeLogsResult.value! {
            
            guard let assignedHashtags = timeLog.hashtags else {
                continue
            }
            
            for hashtag in assignedHashtags {
                hashtagTotalsDictionary[hashtag.name]
                    = ( hashtagTotalsDictionary[hashtag.name] ?? 0 ) + Double(timeLog.durationInMinutes())
            }
        }
        
        return hashtagTotalsDictionary
    }
}