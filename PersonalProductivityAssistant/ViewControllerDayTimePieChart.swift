//
//  ViewControllerDayTimePieChart.swift
//  PersonalProductivityAssistant
//
//  Created by Stefan Mehnert on 29/06/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import UIKit

class ViewControllerDayTimePieChart: UIViewController {
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    let chartDataSource = ChartSourceFreeVsUsedTime()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let chartData = chartDataSource.getChartData()
        
        setChart(chartData.dataPoints, values: chartData.values)
        
        pieChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInCirc)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        
        pieChartDataSet.colors = colors
    }
}
