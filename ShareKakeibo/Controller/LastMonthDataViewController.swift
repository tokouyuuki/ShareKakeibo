//
//  LastMonthDataViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Charts

class LastMonthDataViewController: UIViewController,LoadOKDelegate {

    //追加
    @IBOutlet weak var showDetailButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var userPaymentLastMonth: UILabel!
    @IBOutlet weak var paymentAverageOfLastMonth: UILabel!
    @IBOutlet weak var groupPaymentOfLastMonth: UILabel!
    
    var graphModel = GraphModel()
    //追加
    var loadDBModel = LoadDBModel()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var userID = String()
    let dateFormatter = DateFormatter()
    var year = String()
    var month = String()
    var startDate = Date()
    var endDate = Date()
    
    var categorypay = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showDetailButton.layer.cornerRadius = 5
        
        categorypay = [10,10,10,10,19,3,24]
        graphModel.setPieCht(piecht: pieChartView, categorypay: categorypay)
        
        //追加
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //追加
    //決済日取得完了
    //先月を求める
    func loadSettlementDay_OK(settlementDay: String) {
        activityIndicatorView.stopAnimating()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        if month == "1"{
            startDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\("11")月\(settlementDay)日")!
            endDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\(12)月\(settlementDay)日")!
        }else{
            startDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 2))月\(settlementDay)日")!
            endDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 1))月\(settlementDay)日")!
        }
        loadDBModel.loadCategoryGraphOfTithMonth(groupID: groupID, startDate: startDate, endDate: endDate, activityIndicatorView: activityIndicatorView)
    }
    
    //追加
    //グラフに反映するカテゴリ別合計金額取得完了
    func loadCategoryGraphOfTithMonth_OK(categoryPayArray: [Int]) {
        activityIndicatorView.stopAnimating()
        graphModel.setPieCht(piecht: pieChartView, categorypay: categoryPayArray)
        loadDBModel.loadMonthPayment(groupID: groupID, startDate: startDate, endDate: endDate)
    }
    
    //追加
    //グループの合計出資額、1人当たりの出資額を取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        self.groupPaymentOfLastMonth.text = String(groupPaymentOfMonth) + "　円"
        self.paymentAverageOfLastMonth.text = String(paymentAverageOfMonth) + "　円"
        self.userPaymentLastMonth.text = "0　円"
        //自分の支払額を取得完了
        loadDBModel.loadMonthSettlement(groupID: groupID, userID: userID, userIDArray: nil, startDate: startDate, endDate: endDate) { myTotalPay, userID in
            
            self.userPaymentLastMonth.text = String(myTotalPay) + "　円"
        }
    }
    
    @IBAction func showDetailButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailLastMonthVC", sender: nil)
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
