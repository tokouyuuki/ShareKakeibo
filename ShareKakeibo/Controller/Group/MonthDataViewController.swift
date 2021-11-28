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
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var thisMonthLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var configurationButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerIndicator: UIActivityIndicatorView!
    
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
    
    var changeCommaModel = ChangeCommaModel()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    var dateModel = DateModel()
    var settlementDayOfInt = Int()
    
    
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
        
        backButton.backgroundColor = .darkGray.withAlphaComponent(0.7)
        backButton.tintColor = .white.withAlphaComponent(1)
        backButton.layer.cornerRadius = 20
        
        groupNameLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        groupNameLabel.layer.shadowOpacity = 0.7
        groupNameLabel.layer.shadowRadius = 1
        
        let refreshControl = UIRefreshControl()

        self.view.bringSubviewToFront(refreshControl)
        refreshControl.tintColor = .black
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.refreshControl = refreshControl

        scrollView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        blurView.alpha = 0.3
        self.extendedLayoutIncludesOpaqueBars = true
        
        headerIndicator.style = .medium
        headerIndicator.color = .white
        headerIndicator.isHidden = true

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        activityIndicatorView.startAnimating()
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
    
    @IBAction func backButton(_ sender: Any) {
        print(self.navigationController?.viewControllers)
        navigationController?.popViewController(animated: true)
    }
    
    
}
// MARK: - LoadOKDelegate
extension MonthDataViewController:LoadOKDelegate {
    
    //決済日取得完了
    func loadSettlementDay_OK(settlementDay: String) {
        UserDefaults.standard.setValue(settlementDay, forKey: "settlementDay")
        settlementDayOfInt = Int(settlementDay)!
        loadDBModel.loadGroupName(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //グループ画像、グループ名を取得完了
    func loadGroupName_OK(groupName: String, groupImage: String) {
        UserDefaults.standard.setValue(groupName, forKey: "groupName")
        UserDefaults.standard.setValue(groupImage, forKey: "groupImage")
        groupNameLabel.text = groupName
        groupImageView.sd_setImage(with: URL(string: groupImage), completed: nil)
        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadCategoryGraphOfTithMonth(groupID: groupID, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
        }
    }
    
    //グラフに反映するカテゴリ別合計金額取得完了
    func loadCategoryGraphOfTithMonth_OK(categoryDic: Dictionary<String, Int>) {
        let sortedCategoryDic = categoryDic.sorted{ $0.1 > $1.1 }
        print("*******************")
        print(sortedCategoryDic)
        //        print(sortedCategoryDic[0].key)
        graphModel.setPieCht(piecht: pieChartView, categoryDic: sortedCategoryDic)
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //グループに参加しているメンバーを取得完了
    func loadUserIDAndSettlementDic_OK(settlementDic: Dictionary<String, Bool>, userIDArray: [String]) {
        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            dateFormatter.dateFormat = "MM/dd"
            dateFormatter.locale = Locale(identifier: "ja_JP")
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            let maxdd = Calendar.current.date(byAdding: .day, value: -1, to: maxDate)
            let maxDateFormatter = dateFormatter.string(from: maxdd!)
            let minDateFormatter = dateFormatter.string(from: minDate)
            thisMonthLabel.text = "\(minDateFormatter)〜\(maxDateFormatter)"
            loadDBModel.loadMonthPayment(groupID: groupID, userIDArray: userIDArray, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
        }
    }
    
    //グループの合計出資額、1人当たりの出資額を取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        self.groupPaymentOfThisMonth.text = changeCommaModel.getComma(num: groupPaymentOfMonth) + "　円"
        self.paymentAverageOfTithMonth.text = changeCommaModel.getComma(num: paymentAverageOfMonth) + "　円"
        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadMonthSettlement(groupID: groupID, userID: userID, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
        }
    }
    
    //自分の支払額を取得完了
    func loadMonthSettlement_OK() {
        self.userPaymentThisMonth.text = changeCommaModel.getComma(num: loadDBModel.settlementSets[0].paymentAmount!) + "　円"
        activityIndicatorView.stopAnimating()
    }
    
    
}

// MARK: - ScrollView
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
    
    @objc func refresh() {
   
        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadCategoryGraphOfTithMonth(groupID: groupID, startDate: minDate, endDate: maxDate, activityIndicatorView: activityIndicatorView)
            headerIndicator.isHidden = false
            headerIndicator.startAnimating()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.headerIndicator.isHidden = true
            self.headerIndicator.stopAnimating()
        }
        scrollView.refreshControl?.endRefreshing()
    }
    
}

// MARK: - GoToVcDelegate
extension MonthDataViewController:GoToVcDelegate{
    
    func goToVC(segueID: String) {
        if segueID != ""{
            performSegue(withIdentifier: segueID, sender: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GroupConfigurationVC"{
            let GroupConfigurationVC = segue.destination as! GroupConfigurationViewController
            GroupConfigurationVC.groupImage = groupImageView.image!
        }
    }
    
}


