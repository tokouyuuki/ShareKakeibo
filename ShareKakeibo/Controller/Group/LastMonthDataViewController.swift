//
//  LastMonthDataViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Charts

class LastMonthDataViewController: UIViewController {
    
    
    @IBOutlet weak var showDetailButton: UIButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var userPaymentLastMonth: UILabel!
    @IBOutlet weak var paymentAverageOfLastMonth: UILabel!
    @IBOutlet weak var groupPaymentOfLastMonth: UILabel!
    
    var graphModel = GraphModel()
    var loadDBModel = LoadDBModel()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var userID = String()
    var dateModel = DateModel()
    var settlementDayOfInt = Int()
    
    var changeCommaModel = ChangeCommaModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showDetailButton.layer.cornerRadius = 5
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadOKDelegate = self
        activityIndicatorView.startAnimating()
        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    
    @IBAction func showDetailButton(_ sender: Any) {
        performSegue(withIdentifier: "DetailLastMonthVC", sender: nil)
    }

    
}

//MARK: - LoadOKDelegate

extension LastMonthDataViewController:LoadOKDelegate{
    
    
    //決済日取得完了
    //先月を求める
    func loadSettlementDay_OK(settlementDay: String) {
        settlementDayOfInt = Int(settlementDay)!
        dateModel.getPeriodOfLastMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadCategoryGraphOfTithMonth(groupID: groupID, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
        }
    }
    
    //グラフに反映するカテゴリ別合計金額取得完了
    func loadCategoryGraphOfTithMonth_OK(categoryDic: Dictionary<String, Int>) {
        let sortedCategoryDic = categoryDic.sorted{ $0.1 > $1.1 }
        graphModel.setPieCht(piecht: pieChartView, categoryDic: sortedCategoryDic)
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //グループに参加しているメンバーを取得完了
    func loadUserIDAndSettlementDic_OK(settlementDic: Dictionary<String, Bool>, userIDArray: [String]) {
        dateModel.getPeriodOfLastMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadMonthPayment(groupID: groupID, userIDArray: userIDArray, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
        }
    }

    //グループの合計出資額、1人当たりの出資額を取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        self.groupPaymentOfLastMonth.text = changeCommaModel.getComma(num: groupPaymentOfMonth) + " 円"
        self.paymentAverageOfLastMonth.text = changeCommaModel.getComma(num: paymentAverageOfMonth) + " 円"
        dateModel.getPeriodOfLastMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadMonthSettlement(groupID: groupID, userID: userID, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
        }
    }
    
    //自分の支払額を取得完了
    func loadMonthSettlement_OK() {
        self.userPaymentLastMonth.text = changeCommaModel.getComma(num: loadDBModel.settlementSets[0].paymentAmount!) + " 円"
        activityIndicatorView.stopAnimating()
    }
    
    
}
