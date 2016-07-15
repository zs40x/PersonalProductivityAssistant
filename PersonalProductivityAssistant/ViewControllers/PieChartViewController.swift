//
//  ChartViewController.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 15/07/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class PieChartViewController: UIViewController, SegueHandlerType, ChartViewDelegate  {
    
    var chartDataValueProvider: ChartDataValueProvider?
    
    enum SegueIdentifier : String {
        case UnwindToMainView
    }
    
    
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
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        performSegueWithIdentifier(.UnwindToMainView, sender: self)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Free vs. spent time")
        
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        
        pieChartDataSet.colors
            = [UIColor.greenColor(), UIColor.redColor(), UIColor.brownColor(), UIColor.cyanColor(),
               UIColor.purpleColor(), UIColor.orangeColor(), UIColor.magentaColor()]
    }
}
