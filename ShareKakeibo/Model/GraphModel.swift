//
//  GraphModel.swift
//  kakeiboApp
//
//  Created by nishimaru on 2021/10/23.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import Foundation
import UIKit
import Charts


class ChartFormatter: NSObject, IAxisValueFormatter {
    let xAxisValues = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        //granularityを１.０、labelCountを１２にしているおかげで引数のvalueは1.0, 2.0, 3.0・・・１１.０となります。
        let index = Int(value)
        return xAxisValues[index]
    }
}

class GraphModel{
    
    @IBInspectable var animationDuration: Double = 0.8
    
    let shokuhiColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
    let suidouColor = UIColor(red: 218 / 255, green: 251 / 255, blue: 255 / 255, alpha: 1.0)
    let denkiColor = UIColor(red: 250 / 255, green: 255 / 255, blue: 140 / 255, alpha: 1.0)
    let gasColor = UIColor(red: 255 / 255, green: 149 / 255, blue: 97 / 255, alpha: 1.0)
    let tushinColor = UIColor(red: 146 / 255, green: 255 / 255, blue: 151 / 255, alpha: 1.0)
    let yachinColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 177 / 255, alpha: 1.0)
    let sonotaColor = UIColor.systemGray3
    
    
    func setLineCht(linechart: LineChartView,yAxisValues: [Int]) {
        
        var dataSets = [LineChartDataSet]()
        
        let entries = yAxisValues.enumerated().map{ ChartDataEntry(x: Double($0.offset), y: Double($0.element)) }
        let dataSet = LineChartDataSet(entries: entries, label: "月毎の合計支出(円)")
        dataSets.append(dataSet)
        linechart.data = LineChartData(dataSets: dataSets as [IChartDataSet])
        
        let formatter = ChartFormatter()
        linechart.xAxis.valueFormatter = formatter
        //labelCountはChartDataEntryと同じ数だけ入れます。
        linechart.xAxis.labelCount = 12
        //granularityは1.0で固定
        linechart.xAxis.granularity = 1.0
        
        linechart.animate(xAxisDuration: 0.5)
    }
    
    
    
    func setPieCht(piecht: PieChartView,categorypay: [Int]){
        
        let category = ["食費", "水道代", "電気代", "ガス代", "通信費","家賃","その他"]
        let colors: [UIColor] = [shokuhiColor,suidouColor,denkiColor,gasColor,tushinColor,yachinColor,sonotaColor]
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<category.count {
            if categorypay[i] == 0{
                dataEntries.append(PieChartDataEntry(value: Double(categorypay[i]), label: ""))
            }else{
                dataEntries.append(PieChartDataEntry(value: Double(categorypay[i]), label: category[i]))
            }
        }
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "個人のカテゴリー別支出(円)")
        
        pieChartDataSet.colors = colors
        pieChartDataSet.valueTextColor = NSUIColor.black
        pieChartDataSet.entryLabelColor = NSUIColor.black

        piecht.data = PieChartData(dataSet: pieChartDataSet)
        piecht.animate(yAxisDuration: 2)
        piecht.rotationEnabled = false
        piecht.highlightPerTapEnabled = false
        
    }
    
    
}
