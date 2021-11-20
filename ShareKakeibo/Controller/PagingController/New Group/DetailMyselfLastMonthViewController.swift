////
////  DetailMyselfViewController.swift
////  Test
////
////  Created by 近藤大伍 on 2021/11/04.
////
//
//import UIKit
//import Parchment
//
//class DetailMyselfLastMonthViewController: UIViewController {
//    
//    var loadDBModel = LoadDBModel()
//    var editDBModel = EditDBModel()
//    var monthMyDetailsSets = [MonthMyDetailsSets]()
//    var activityIndicatorView = UIActivityIndicatorView()
//    var groupID = String()
//    var userID = String()
//    let dateFormatter = DateFormatter()
//    var year = String()
//    var month = String()
//    var startDate = Date()
//    var endDate = Date()
//    var tableView = UITableView()
//    var profileImage = String()
//    var userName = String()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.separatorStyle = .none
//        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
//        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
//        self.view.addSubview(tableView)
//        
//        activityIndicatorView.center = view.center
//        activityIndicatorView.style = .large
//        activityIndicatorView.color = .darkGray
//        view.addSubview(activityIndicatorView)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        let calendar = Calendar(identifier: .gregorian)
//        let date = calendar.dateComponents([.year,.month], from: Date())
//        year = String(date.year!)
//        month = String(date.month!)
//        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
//        userID = UserDefaults.standard.object(forKey: "userID") as! String
//        loadDBModel.loadOKDelegate = self
//        editDBModel.editOKDelegate = self
//        loadDBModel.loadSettlementDay(groupID: groupID, activityIndicatorView: activityIndicatorView)
//    }
//    
//}
//
//// MARK: - LoadOKDelegate,EditOKDelegate
//
//extension DetailMyselfLastMonthViewController:LoadOKDelegate,EditOKDelegate{
//    //決済日取得完了
//    //決済月を求める
//    func loadSettlementDay_OK(settlementDay: String) {
//        activityIndicatorView.stopAnimating()
//        dateFormatter.dateFormat = "yyyy年MM月dd日"
//        dateFormatter.locale = Locale(identifier: "ja_JP")
//        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
//        if month == "1"{
//            startDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\("11")月\(settlementDay)日")!
//            endDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\(12)月\(settlementDay)日")!
//        }else{
//            startDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 2))月\(settlementDay)日")!
//            endDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 1))月\(settlementDay)日")!
//        }
//        loadDBModel.loadMonthDetails(groupID: groupID, startDate: startDate, endDate: endDate, userID: userID, activityIndicatorView: activityIndicatorView)
//    }
//    
//    //自分の明細を取得完了
//    func loadMonthDetails_OK() {
//        activityIndicatorView.stopAnimating()
//        monthMyDetailsSets = loadDBModel.monthMyDetailsSets
//        //変更
//        loadDBModel.loadUserInfo(userID: userID, activityIndicatorView: activityIndicatorView)
//    }
//    
//    //自分のユーザーネーム、プロフィール画像を取得完了
//    func loadUserInfo_OK(userName: String, profileImage: String, email: String, password: String) {
//        self.profileImage = profileImage
//        self.userName = userName
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        tableView.reloadData()
//    }
//    
//    //データ削除完了
//    func editMonthDetailsDelete_OK() {
//        monthMyDetailsSets = []
//        monthMyDetailsSets = editDBModel.monthMyDetailsSets
//        tableView.reloadData()
//    }
//    
//}
//
//// MARK: - TableView
//
//extension DetailMyselfLastMonthViewController:UITableViewDelegate,UITableViewDataSource{
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return monthMyDetailsSets.count
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
//        
//        cell.profileImage.sd_setImage(with: URL(string: profileImage), completed: nil)
//        cell.paymentLabel.text = String(monthMyDetailsSets[indexPath.row].paymentAmount)
//        cell.userNameLabel.text = userName
//        cell.dateLabel.text = monthMyDetailsSets[indexPath.row].paymentDay
//        cell.category.text = monthMyDetailsSets[indexPath.row].category
//        cell.view.layer.cornerRadius = 5
//        cell.view.layer.masksToBounds = false
//        cell.view.layer.shadowOffset = CGSize(width: 1, height: 3)
//        cell.view.layer.shadowOpacity = 0.2
//        cell.view.layer.shadowRadius = 3
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        
//        // 削除のアクションを設定する
//        let deleteAction = UIContextualAction(style: .destructive, title:"delete") { [self]
//            (ctxAction, view, completionHandler) in
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            //データ削除
//            
//            completionHandler(true)
//        }
//        // 削除ボタンのデザインを設定する
//        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
//        deleteAction.image = trashImage
//        deleteAction.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
//        
//        // スワイプでの削除を無効化して設定する
//        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
//        swipeAction.performsFirstActionWithFullSwipe = false
//        
//        return swipeAction
//        
//    }
//    
//}
