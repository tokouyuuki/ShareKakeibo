//
//  MonthDataViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Charts
import SDWebImage


class MonthDataViewController: UIViewController,GoToVcDelegate,UIScrollViewDelegate,LoadOKDelegate {
    
    
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var configurationButton: UIButton!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var userPaymentThisMonth: UILabel!
    @IBOutlet weak var groupPaymentOfThisMonth: UILabel!
    @IBOutlet weak var paymentAverageOfTithMonth: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var thisMonthLabel: UILabel!

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
        
        configurationButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        configurationButton.layer.shadowOpacity = 0.7
        configurationButton.layer.shadowRadius = 1

        groupNameLabel.layer.shadowOpacity = 0.7
        scrollView.delegate = self
        scrollView.contentInsetAdjustmentBehavior = .never
        blurView.alpha = 0
        
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
        thisMonthLabel.text = year + "年" + month + "月分"
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //決済日取得完了
    func loadSettlementDay_OK(settlementDay: String) {
        activityIndicatorView.stopAnimating()
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
    func loadCategoryGraphOfTithMonth_OK(categoryPayArray: [Int]) {
        activityIndicatorView.stopAnimating()
        graphModel.setPieCht(piecht: pieChartView, categorypay: categoryPayArray)
        //変更
        loadDBModel.loadMonthPayment(groupID: groupID, startDate: startDate, endDate: endDate)
    }
    
    //グループの合計出資額、1人当たりの出資額を取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        self.groupPaymentOfThisMonth.text = String(groupPaymentOfMonth) + "　円"
        self.paymentAverageOfTithMonth.text = String(paymentAverageOfMonth) + "　円"
        self.userPaymentThisMonth.text = "0　円"
        //自分の支払額を取得完了
        loadDBModel.loadMonthSettlement(groupID: groupID, userID: userID, userIDArray: nil, startDate: startDate, endDate: endDate) { myTotalPay, userID in
            
            self.userPaymentThisMonth.text = String(myTotalPay) + "　円"
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)

        headerViewHeightConstraint.constant = max(150 - scrollView.contentOffset.y, 85)
        groupNameBottomConstraint.constant = max(5, 32 - scrollView.contentOffset.y)
        configurationButtonBottomConstraint.constant = max(5, 26 - scrollView.contentOffset.y)
        blurView.alpha = (0.7 / 85) * scrollView.contentOffset.y
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
    
    func goToVC(segueID: String) {
        performSegue(withIdentifier: segueID, sender: nil)
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
