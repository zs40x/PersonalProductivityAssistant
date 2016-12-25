//
//  ChartDataValueProvider.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation

struct ChartDataValues {
    let dataPoints: [String]
    let values: [Double]
}

protocol ChartDataValueProvider {
    func getChartData() -> ChartDataValues
}