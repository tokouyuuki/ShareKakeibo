//
//  SettlementViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import ViewAnimator
import SDWebImage
import FirebaseFirestore


class SettlementViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,LoadOKDelegate{
    
    
    @IBOutlet weak var userPaymentOfLastMonth: UILabel!
    @IBOutlet weak var settlementCompletionButton: UIButton!
    @IBOutlet weak var checkDetailButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var loadDBModel = LoadDBModel()
    var db = Firestore.firestore()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var userID = String()
    var year = String()
    var month = String()
    let dateFormatter = DateFormatter()
    var startDate = Date()
    var endDate = Date()
    var userNameArray = [String]()
    var profileImageArray = [String]()
    var settlementArray = [Bool]()
    var howMuchArray = [Int]()
    var settlementDic = Dictionary<String,Bool>()
    //追加
    var userIDArray = [String]()
    var groupPaymentOfMonth = Int()
    var paymentAverageOfMonth = Int()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settlementCompletionButton.layer.cornerRadius = 5
        settlementCompletionButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        settlementCompletionButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        checkDetailButton.layer.cornerRadius = 5
        checkDetailButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        checkDetailButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let animation = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
        tableView.separatorStyle = .none
        UIView.animate(views: tableView.visibleCells, animations: animation, completion:nil)
        
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //決済日取得完了
    //決済月を求める
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
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    //メンバーの決済可否を取得完了
    func loadUserIDAndSettlementDic_OK(settlementDic: Dictionary<String, Bool>, userIDArray: [String]) {
        self.settlementDic = settlementDic
        settlementArray = Array(settlementDic.values)
        loadDBModel.loadMonthPayment(groupID: groupID, userIDArray: userIDArray, startDate: startDate, endDate: endDate)
    }
    
    //変更
    //(グループの合計金額)と(1人当たりの金額)と(支払いに参加したユーザーの数)取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        //        var totalDic = Dictionary<String,Int>()
        self.userIDArray = userIDArray
        self.paymentAverageOfMonth = paymentAverageOfMonth
        loadDBModel.loadMonthSettlement(groupID: groupID, userID: nil, startDate: startDate, endDate: endDate)
        
        //グループの支払い状況の取得完了
        //        loadDBModel.loadMonthSettlement(groupID: groupID, userID: nil, userIDArray: userIDArray, startDate: startDate, endDate: endDate) { [self] myTotalPay, userID in
        //            totalDic.updateValue(myTotalPay, forKey: userID)
        //            //各メンバーの決済額の配列
        //            howMuchArray = totalDic.map{($1 - paymentAverageOfMonth) * -1}
        //            //自分の決済額
        //            var userPayment = totalDic[userID]!
        //            userPayment = paymentAverageOfMonth - userPayment
        //            if userPayment < 0{
        //                userPaymentOfLastMonth.text = "あなたは" + String(userPayment * -1) + "の受け取りがあります"
        //            }else{
        //                userPaymentOfLastMonth.text = "あなたは" + String(userPayment) + "の支払いがあります"
        //            }
        //            loadDBModel.loadTableView(userIDArray: userIDArray)
        //        }
    }
    
    //追加
    //グループの支払い状況の取得完了
    func loadMonthSettlement_OK() {
        howMuchArray = []
        profileImageArray = []
        userNameArray = []
        var Dic = Dictionary<String,Int>()
        
        for ID in userIDArray{
            var totalPay = 0
            if (loadDBModel.settlementSets.count != 0){
                for count in 0...loadDBModel.settlementSets.count - 1{
                    if ID == loadDBModel.settlementSets[count].userID{
                        totalPay = totalPay + loadDBModel.settlementSets[count].paymentAmount!
                    }
                }
            }else{
                return
            }
            //各メンバーの支払金額の配列
            Dic.updateValue(totalPay, forKey: ID)
        }
        
        //各メンバーの決済額の配列
        howMuchArray = Dic.map{($1 - paymentAverageOfMonth) * -1}
        
        //自分の決済額
        var userPayment = Dic[userID]!
        userPayment = paymentAverageOfMonth - userPayment
        if userPayment < 0{
            userPaymentOfLastMonth.text = "あなたは" + String(userPayment * -1) + "の受け取りがあります"
        }else{
            userPaymentOfLastMonth.text = "あなたは" + String(userPayment) + "の支払いがあります"
        }
        
        //各メンバーのプロフィール画像、名前取得完了
        print(userIDArray)
        loadDBModel.loadGroupMember(userIDArray: userIDArray) { UserSets in
            self.profileImageArray.append(UserSets.profileImage)
            self.userNameArray.append(UserSets.userName)
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    @IBAction func settlementCompletionButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        
        //変更
        if settlementDic[userID] == true{
            db.collection("groupManagement").document(groupID).setData(["settlementDic" : [userID:false]],merge: true)
        }else{
            db.collection("groupManagement").document(groupID).setData(["settlementDic" : [userID:true]],merge: true)
        }
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    @IBAction func checkDetailButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        performSegue(withIdentifier: "lastMonthDataVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settlementArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let cellView = cell?.contentView.viewWithTag(1) as! UIView
        let profileImage = cell?.contentView.viewWithTag(2) as! UIImageView
        let userNameLabel = cell?.contentView.viewWithTag(3) as! UILabel
        let checkSettlementLabel = cell?.contentView.viewWithTag(4) as! UILabel
        let howMuchLabel = cell?.contentView.viewWithTag(5) as! UILabel
        
        print("とこうです")
        print(profileImageArray)
        print(userNameArray)
        
        profileImage.layer.cornerRadius = 30
        profileImage.sd_setImage(with: URL(string: profileImageArray[indexPath.row]), completed: nil)
        userNameLabel.text = userNameArray[indexPath.row]
        
        checkSettlementLabel.layer.cornerRadius = 5
        if settlementArray[indexPath.row] == true{
            checkSettlementLabel.text = "決済済み"
            checkSettlementLabel.backgroundColor = .systemGreen
        }else{
            checkSettlementLabel.text = "未決済"
            checkSettlementLabel.backgroundColor = .systemRed
        }
        //変更
        if howMuchArray[indexPath.row] < 0{
            howMuchLabel.text = String(howMuchArray[indexPath.row] * -1 ) + "の支払"
        }else{
            howMuchLabel.text = String(howMuchArray[indexPath.row]) + "の受取"
        }
        cellView.layer.cornerRadius = 5
        cellView.layer.masksToBounds = false
        cellView.layer.cornerRadius = 5
        cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowRadius = 1
        
        return cell!
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
