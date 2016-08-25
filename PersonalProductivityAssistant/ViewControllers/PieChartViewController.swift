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
        
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInCirc)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlighter) {
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: values[i], y: Double(i))
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Free vs. spent time")
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)

        pieChartView.data = pieChartData
        
        
        pieChartDataSet.colors
            = [UIColor.greenColor(), UIColor.redColor(), UIColor.brownColor(), UIColor.cyanColor(),
               UIColor.purpleColor(), UIColor.orangeColor(), UIColor.magentaColor()]
    }
}
