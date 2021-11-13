//
//  DetailMyselfViewController.swift
//  Test
//
//  Created by 近藤大伍 on 2021/11/04.
//

import UIKit
import Parchment

class DetailAllLastMonthViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,LoadOKDelegate {
    
    var loadDBModel = LoadDBModel()
    var monthGroupDetailsSets = [MonthGroupDetailsSets]()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    let dateFormatter = DateFormatter()
    var year = String()
    var month = String()
    var startDate = Date()
    var endDate = Date()
    var tableView = UITableView()
    var userIDArray = [String]()
    var profileImageArray = [String]()
    var userNameArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "detailCell")
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        self.view.addSubview(tableView)
        
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
        if month == "1"{
            startDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\("11")月\(settlementDay)日")!
            endDate = dateFormatter.date(from: "\(String(Int(year)! - 1))年\(12)月\(settlementDay)日")!
        }else{
            startDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 2))月\(settlementDay)日")!
            endDate = dateFormatter.date(from: "\(year)年\(String(Int(month)! - 1))月\(settlementDay)日")!
        }
        
        loadDBModel.loadMonthDetails(groupID: groupID, startDate: startDate, endDate: endDate, userID: nil, activityIndicatorView: activityIndicatorView)
    }
    
    //全体の明細を取得完了
    func loadMonthDetails_OK() {
        activityIndicatorView.stopAnimating()
        monthGroupDetailsSets = loadDBModel.monthGroupDetailsSets
        //変更
        userIDArray = []
        profileImageArray = []
        userNameArray = []
        if monthGroupDetailsSets.count != 0{
            for i in 0...monthGroupDetailsSets.count - 1{
                userIDArray.append(monthGroupDetailsSets[i].userID)
            }
        }
        
        //明細に表示するユーザーネームとプロフィール画像取得
        loadDBModel.loadGroupMember(userIDArray: userIDArray) { [self] UserSets in
            self.profileImageArray.append(UserSets.profileImage)
            self.userNameArray.append(UserSets.userName)
            
            tableView.delegate = self
            tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
        
        //変更
        cell.profileImage.sd_setImage(with: URL(string: profileImageArray[indexPath.row]), completed: nil)
        cell.paymentLabel.text = String(monthGroupDetailsSets[indexPath.row].paymentAmount)
        cell.userNameLabel.text = userNameArray[indexPath.row]
        cell.dateLabel.text = monthGroupDetailsSets[indexPath.row].paymentDay
        cell.category.text = monthGroupDetailsSets[indexPath.row].category
        
        return cell
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
