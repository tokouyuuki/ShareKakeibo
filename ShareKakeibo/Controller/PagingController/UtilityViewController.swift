//
//  LivingViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/22.
//

import UIKit
import Charts

class UtilityViewController: UIViewController,LoadOKDelegate {

    var graphModel = GraphModel()
    var yAxisValues = [Int]()
    var loadDBModel = LoadDBModel()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var year = String()
    let dateFormatter = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year], from: Date())
        year = String(date.year!)
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //決済日取得完了
    //今年の期間を定める
    func loadSettlementDay_OK(settlementDay: String) {
        activityIndicatorView.stopAnimating()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        startDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\("12")月\(settlementDay)日")!
        endDate = dateFormatter.date(from: "\(year)年\("12")月\(settlementDay)日")!
        loadDBModel.loadMonthlyUtilityTransition(groupID: groupID, year: year, settlementDay: settlementDay, startDate: startDate, endDate: endDate, activityIndicatorView: activityIndicatorView)
    }
    
    //１〜１２月の光熱費の推移取得完了
    func loadMonthlyTransition_OK(countArray: [Int]) {
        activityIndicatorView.stopAnimating()
        yAxisValues = countArray
        let lineChartsView = LineChartView()
        graphModel.setLineCht(linechart: lineChartsView, yAxisValues: yAxisValues)
        lineChartsView.frame = CGRect(x: 0, y: 80, width: view.frame.width, height: 350)
        graphModel.setLineCht(linechart: lineChartsView, yAxisValues: yAxisValues)
        self.view.addSubview(lineChartsView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
