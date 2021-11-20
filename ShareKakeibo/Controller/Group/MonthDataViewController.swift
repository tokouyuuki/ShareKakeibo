//
//  MonthDataViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Charts
import SDWebImage


class MonthDataViewController: UIViewController{
    
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var configurationButton: UIButton!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var userPaymentThisMonth: UILabel!
    @IBOutlet weak var groupPaymentOfThisMonth: UILabel!
    @IBOutlet weak var paymentAverageOfTithMonth: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var configurationButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    @IBOutlet weak var pieChartView: PieChartView!
    var graphModel = GraphModel()
    
    var loadDBModel = LoadDBModel()
    var activityIndicatorView = UIActivityIndicatorView()
    var userID = String()
    var groupID = String()
    let dateFormatter = DateFormatter()
    var year = String()
    var month = String()
    var startDate = Date()
    var endDate = Date()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPaymentButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addPaymentButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        addPaymentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addPaymentButton.layer.shadowOpacity = 0.5
        addPaymentButton.layer.shadowRadius = 1
        
        configurationButton.layer.cornerRadius = 30
        configurationButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        configurationButton.layer.shadowOpacity = 0.7
        configurationButton.layer.shadowRadius = 1
        
        groupNameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        groupNameLabel.layer.shadowOpacity = 0.7
        groupNameLabel.layer.shadowRadius = 1
        
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        blurView.alpha = 0.3
        
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
        //        thisMonthLabel.text = year + "年" + month + "月分"
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
        addPaymentButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        addPaymentButton.layer.shadowOpacity = 0
        addPaymentButton.layer.shadowRadius = 0
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        addPaymentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addPaymentButton.layer.shadowOpacity = 0.5
        addPaymentButton.layer.shadowRadius = 1
    }
    
    @IBAction func addPaymentButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        performSegue(withIdentifier: "paymentVC", sender: nil)
        addPaymentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        addPaymentButton.layer.shadowOpacity = 0.5
        addPaymentButton.layer.shadowRadius = 1
    }
    
    @IBAction func configurationButton(_ sender: Any) {
        let GroupDetailVC = storyboard?.instantiateViewController(identifier: "GroupDetailVC") as! GroupDetailViewController
        GroupDetailVC.goToVcDelegate = self
        present(GroupDetailVC, animated: true, completion: nil)
    }
    
}
// MARK: - LoadOKDelegate
extension MonthDataViewController:LoadOKDelegate {
    
    //決済日取得完了
    func loadSettlementDay_OK(settlementDay: String) {
        activityIndicatorView.stopAnimating()
        UserDefaults.standard.setValue(settlementDay, forKey: "settlementDay")
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        if month == "12"{
            startDate = dateFormatter.date(from: "\(year)年\(month)月\(settlementDay)日")!
            endDate = dateFormatter.date(from: "\(String(Int(year)! + 1))年\("1")月\(settlementDay)日")!
        }else{
            startDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 1))月\(settlementDay)日")!
            endDate = dateFormatter.date(from: "\(year)年\((month))月\(settlementDay)日")!
        }
        print("#$&#$%#$%#$%#$%#$%")
        print(startDate)
        print(endDate)
        loadDBModel.loadGroupName(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //グループ画像、グループ名を取得完了
    func loadGroupName_OK(groupName: String, groupImage: String) {
        activityIndicatorView.stopAnimating()
        groupNameLabel.text = groupName
        groupImageView.sd_setImage(with: URL(string: groupImage), completed: nil)
        loadDBModel.loadCategoryGraphOfTithMonth(groupID: groupID, startDate: startDate, endDate: endDate, activityIndicatorView: activityIndicatorView)
    }
    
    //グラフに反映するカテゴリ別合計金額取得完了
    func loadCategoryGraphOfTithMonth_OK(categoryDic: Dictionary<String, Int>) {
        activityIndicatorView.stopAnimating()
        
        let sortedCategoryDic = categoryDic.sorted{ $0.1 > $1.1 }
        print("*******************")
        print(sortedCategoryDic)
        //        print(sortedCategoryDic[0].key)
        graphModel.setPieCht(piecht: pieChartView, categoryDic: sortedCategoryDic)
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    //追加
    //グループに参加しているメンバーを取得完了
    func loadUserIDAndSettlementDic_OK(settlementDic: Dictionary<String, Bool>, userIDArray: [String]) {
        activityIndicatorView.stopAnimating()
        loadDBModel.loadMonthPayment(groupID: groupID, userIDArray: userIDArray, startDate: startDate, endDate: endDate)
    }
    //変更
    //グループの合計出資額、1人当たりの出資額を取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        self.groupPaymentOfThisMonth.text = String(groupPaymentOfMonth) + "　円"
        self.paymentAverageOfTithMonth.text = String(paymentAverageOfMonth) + "　円"
        loadDBModel.loadMonthSettlement(groupID: groupID, userID: userID, startDate: startDate, endDate: endDate)
    }
    //追加
    //自分の支払額を取得完了
    func loadMonthSettlement_OK() {
        self.userPaymentThisMonth.text = String(loadDBModel.settlementSets[0].paymentAmount!) + "　円"
    }
    
}

// MARK: - UIScrollViewDelegate
extension MonthDataViewController:UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        
        headerViewHeightConstraint.constant = max(150 - scrollView.contentOffset.y, 85)
        groupNameBottomConstraint.constant = max(5, 26 - scrollView.contentOffset.y)
        configurationButtonBottomConstraint.constant = max(0, 19 - scrollView.contentOffset.y)
        if scrollView.contentOffset.y >= 0.2{
            blurView.alpha = (0.7 / 85) * scrollView.contentOffset.y
        }else{
            blurView.alpha = 0.3
        }
    }
    
}

// MARK: - GoToVcDelegate
extension MonthDataViewController:GoToVcDelegate{
    
    func goToVC(segueID: String) {
        performSegue(withIdentifier: segueID, sender: nil)
    }
    
}
