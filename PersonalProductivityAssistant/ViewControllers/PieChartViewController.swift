//
//  ChartViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit
import Charts

class PieChartViewController: UIViewController, ChartViewDelegate  {
    
    var chartDataValueProvider: ChartDataValueProvider?

    
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChartView.delegate = self
        
        self.loadDataAndDisplayChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Helper Methods
    func loadDataAndDisplayChart() {
        
        guard let dataProvider = self.chartDataValueProvider else {
            return
        }
        
        let chartData = dataProvider.getChartData()
        setChart(chartData.dataPoints, values: chartData.values)
        
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInCirc)
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlighter) {
        
    }
    
    func setChart(_ dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Free vs. spent time")
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)

        pieChartView.data = pieChartData
        
        
        pieChartDataSet.colors
            = [UIColor.green, UIColor.red, UIColor.brown, UIColor.cyan,
               UIColor.purple, UIColor.orange, UIColor.magenta]
    }
}
