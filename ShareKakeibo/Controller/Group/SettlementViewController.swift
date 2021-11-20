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


class SettlementViewController: UIViewController{
    
    
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
    var userNameDic = Dictionary<String,String>()
    var profileImageDic = Dictionary<String,String>()
    var howMuchArray = [Int]()
    var paymentDic = Dictionary<String,Int>()
    var userIDArray = [String]()
    var paymentAverageOfMonth = Int()
    
    var sortedSettlementDic = [Dictionary<String,Bool>.Element]()
    var sortedProfileImageDic = [Dictionary<String,String>.Element]()
    var sortedUserNameDic = [Dictionary<String,String>.Element]()
    var sortedPaymentDic = [Dictionary<String,Int>.Element]()
    
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
    
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    @IBAction func settlementCompletionButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        
        for (key,value) in sortedSettlementDic{
            if key == userID && value == true{
                db.collection("groupManagement").document(groupID).setData(["settlementDic" : [userID:false]],merge: true)
            }else if key == userID && value == false{
                db.collection("groupManagement").document(groupID).setData(["settlementDic" : [userID:true]],merge: true)
            }
        }
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    @IBAction func checkDetailButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        performSegue(withIdentifier: "lastMonthDataVC", sender: nil)
    }
    
}

// MARK: - LoadOKDelegate
extension SettlementViewController: LoadOKDelegate{
    
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
        sortedSettlementDic = settlementDic.sorted(by: {$0.key < $1.key})
        loadDBModel.loadMonthPayment(groupID: groupID, userIDArray: userIDArray, startDate: startDate, endDate: endDate)
    }
    
    //(グループの合計金額)と(1人当たりの金額)と(支払いに参加したユーザーの数)取得完了
    func loadMonthPayment_OK(groupPaymentOfMonth: Int, paymentAverageOfMonth: Int, userIDArray: [String]) {
        profileImageDic = [:]
        userNameDic = [:]
        self.userIDArray = userIDArray.sorted()
        self.paymentAverageOfMonth = paymentAverageOfMonth
        
        //各メンバーのプロフィール画像、名前取得完了
        loadDBModel.loadGroupMember(userIDArray: userIDArray) { [self] UserSets in
            profileImageDic.updateValue(UserSets.profileImage, forKey: UserSets.userID)
            userNameDic.updateValue(UserSets.userName, forKey: UserSets.userID)
            sortedProfileImageDic = profileImageDic.sorted(by: {$0.key < $1.key})
            sortedUserNameDic = userNameDic.sorted(by: {$0.key < $1.key})
            loadDBModel.loadMonthSettlement(groupID: groupID, userID: nil, startDate: startDate, endDate: endDate)
        }
    }
    
    //グループの支払い状況の取得完了
    func loadMonthSettlement_OK() {
        paymentDic = [:]
        
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
            paymentDic.updateValue(totalPay, forKey: ID)
        }
        sortedPaymentDic = paymentDic.sorted(by: {$0.key < $1.key})
        
        //各メンバーの決済額の配列
        howMuchArray = sortedPaymentDic.map{($1 - paymentAverageOfMonth) * -1}
        
        //自分の決済額
        var userPayment = paymentDic[userID]!
        userPayment = paymentAverageOfMonth - userPayment
        if userPayment < 0{
            userPaymentOfLastMonth.text = "あなたは" + String(userPayment * -1) + "の受け取りがあります"
        }else{
            userPaymentOfLastMonth.text = "あなたは" + String(userPayment) + "の支払いがあります"
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
}

// MARK: - TableView
extension SettlementViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedSettlementDic.count
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
        
        profileImage.layer.cornerRadius = 30
        profileImage.sd_setImage(with: URL(string: sortedProfileImageDic[indexPath.row].value), completed: nil)
        userNameLabel.text = sortedUserNameDic[indexPath.row].value
        
        checkSettlementLabel.layer.cornerRadius = 5
        
        if sortedSettlementDic[indexPath.row].value == true{
            checkSettlementLabel.text = "決済済み"
            checkSettlementLabel.backgroundColor = .systemGreen
        }else{
            checkSettlementLabel.text = "未決済"
            checkSettlementLabel.backgroundColor = .systemRed
        }
        
        if howMuchArray[indexPath.row] < 0{
            howMuchLabel.text = String(howMuchArray[indexPath.row] * -1 ) + "の受取"
        }else{
            howMuchLabel.text = String(howMuchArray[indexPath.row]) + "の支払"
        }
        cellView.layer.cornerRadius = 5
        cellView.layer.masksToBounds = false
        cellView.layer.cornerRadius = 5
        cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowRadius = 1
        
        return cell!
    }
}
