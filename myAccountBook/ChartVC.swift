//
//  ChartVC.swift
//  myAccountBook
//
//  Created by Frank on 2017/7/5.
//  Copyright © 2017年 frankc. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ChartVC: BaseVC {
    
    @IBOutlet weak var barChartView: BarChartView!
    
    let months = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月",]
    var costs: [Double]!

    var perMonthCost: [String:[[String:String]]]! = [:]

    @IBAction func prevYear(_ sender: UIButton!) {
        var dateComponets = DateComponents()
        dateComponets.year = -1
        updateCurrentDate(dateComponets)
        
        updateUI()
    }
    
    @IBAction func nextYear(_ sender: UIButton!) {
        var dateComponets = DateComponents()
        dateComponets.year = 1
        updateCurrentDate(dateComponets)
        
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI() {
        setNavTitle()
        fetchYearRecord()
        setChart(dataPoints: months, value: costs)
    }
    
    func setNavTitle() {
        title = dateFormatter.stringWith(format: "yyyy 年", date: currentDate)
    }
    
    func fetchYearRecord() {
        let year = dateFormatter.stringWith(format: "yyyy", date: currentDate)

        var total = 0.0
        var tempCost = 0.0
        costs = Array(repeating: 0.0, count: 12)
        perMonthCost = [:]

        let fetchRequest: NSFetchRequest = Record.fetchRequest()
        // 日期排序
        let dateSort = NSSortDescriptor(key: "createDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            let results = try context.fetch(fetchRequest)
            for result in results where result.yearMonth.subString(from: 0, to: 3) == "\(year)" {
                
                let createDate = result.value(forKey: "createDate") as! String
                
                if let preSaveCreateMonth = myUserDefaults.object(forKey: "createMonth") {
                    let resultMonth = result.createDate.subString(from: 5, to: 6)
                    
                    if resultMonth == preSaveCreateMonth as! String {
                        tempCost += result.value(forKey: "amount") as! Double
                    } else {
                        tempCost = 0
                        tempCost += result.value(forKey: "amount") as! Double
                    }
                    
                    let monthStr = createDate.subString(from: 5, to: 6)
                    if monthStr != "" {
                        
                        if perMonthCost[monthStr] == nil {
                            perMonthCost[monthStr] = []
                        }
                        
                        perMonthCost[monthStr]?.append([
                            "month":"\(createDate.subString(from: 5, to: 6))",
                            "cost":"\(tempCost)"
                            ])
                    }
                }
                
                // 儲存目前讀到的月份
                myUserDefaults.set(createDate.subString(from: 5, to: 6), forKey: "createMonth")
            }
            
            if perMonthCost.count != 0 {
                for key in perMonthCost.keys {
                    for i in 0..<perMonthCost[key]!.count {
                        total = 0.0
                        total += Double((perMonthCost[key]?[i]["cost"])!)!
                    }
                    
                    let indexForlessThanTen = Int(key.subString(from: 1, to: 1))! - 1
                    let indexForlargerThanNine = Int(key.subString(from: 0, to: 1))! - 1
                    
                    if key == "10" || key == "11" || key == "12" {
                        costs[indexForlargerThanNine] = total
                    } else {
                        costs[indexForlessThanTen] = total
                    }
                }
            }
          
        } catch {
            fatalError("\(error)")
        }
    }
    
    func setChart(dataPoints: [String], value: [Double]) {

        barChartView.noDataText = "沒有記錄可供分析，請先新建一筆紀錄。"
        barChartView.noDataFont = UIFont.systemFont(ofSize: 15)
        barChartView.chartDescription?.text = ""
        
        if perMonthCost.count != 0 {
            var dataEntries = [BarChartDataEntry]()
            
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: value[i])
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
            chartDataSet.highlightEnabled = false
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.setValueFont(UIFont(name: "HelveticaNeue", size: 10.0))
            chartDataSet.colors = ChartColorTemplates.material()
            
            barChartView.doubleTapToZoomEnabled = false
            barChartView.dragEnabled = true
            barChartView.scaleYEnabled = false
            barChartView.legend.enabled = false
            
            // X軸
            let xAxis: XAxis = barChartView.xAxis
            xAxis.axisLineWidth = 1
            xAxis.labelPosition = .bottom
            xAxis.drawGridLinesEnabled = false
            xAxis.labelTextColor = .brown
            xAxis.granularity = 1
            xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
            
            // Y軸
            let leftAxis: YAxis = barChartView.leftAxis
            leftAxis.axisMinimum = 0
            barChartView.rightAxis.enabled = false
            leftAxis.valueFormatter = MyAxisValueFormatter()
            
            // 限制線
            let chartLimitLine = ChartLimitLine(limit: 5000.0)
            chartLimitLine.lineWidth = 2
            chartLimitLine.lineDashLengths = [5.0, 5.0]
            chartLimitLine.labelPosition = .rightTop
            leftAxis.addLimitLine(chartLimitLine)
            leftAxis.drawLimitLinesBehindDataEnabled = false
            
            barChartView.data = chartData
            
            // 動畫
            barChartView.animate(yAxisDuration: 1.0)
        } else {
            barChartView.clear()
        }
    }
}
