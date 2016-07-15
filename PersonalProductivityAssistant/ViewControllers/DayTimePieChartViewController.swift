//
//  ViewControllerDayTimePieChart.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 29/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//
// ::>> http://www.appcoda.com/ios-charts-api-tutorial/
//

import UIKit

class DayTimePieChartViewController: UIViewController, SegueHandlerType, ChartViewDelegate {
    
    let chartDataSource = ChartSourceHashtags()
    
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
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    @IBAction func unwindToDayTimePieChart(segue: UIStoryboardSegue) {
        
    }
    
    
    // MARK: - Helper Methods
    func loadDataAndDisplayChart() {
        let chartData = chartDataSource.getChartData()
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
        
        
        var colors: [UIColor] = []
        
        colors.append(UIColor.greenColor())
        colors.append(UIColor.redColor())
        colors.append(UIColor.brownColor())
        colors.append(UIColor.cyanColor())
        colors.append(UIColor.purpleColor())
        colors.append(UIColor.purpleColor())
        colors.append(UIColor.orangeColor())
        colors.append(UIColor.magentaColor())
        
        pieChartDataSet.colors = colors
    }
}
