//
//  DetailMyselfViewController.swift
//  Test
//
//  Created by 近藤大伍 on 2021/11/04.
//

import UIKit
import Parchment
import Firebase
import FirebaseFirestore

class DetailMyselfViewController: UIViewController {
    
    
    var loadDBModel = LoadDBModel()
    var monthMyDetailsSets = [MonthMyDetailsSets]()
    var activityIndicatorView = UIActivityIndicatorView()
    var groupID = String()
    var userID = String()
    let dateFormatter = DateFormatter()
    var year = String()
    var month = String()
    var startDate = Date()
    var endDate = Date()
    var tableView = UITableView()
    var profileImage = String()
    var userName = String()
    var indexPath = IndexPath()
    var settlementDay = String()
    
    var db = Firestore.firestore()
    var dateModel = DateModel()
    var changeCommaModel = ChangeCommaModel()
    
    
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
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        settlementDay = UserDefaults.standard.object(forKey: "settlementDay") as! String
        
        let settlementDayOfInt = Int(settlementDay)!
        activityIndicatorView.startAnimating()
        loadDBModel.loadOKDelegate = self
        dateModel.getPeriodOfThisMonth(settelemtDay: settlementDayOfInt) { maxDate, minDate in
            loadDBModel.loadMonthDetails(groupID: groupID, startDate: minDate, endDate: maxDate, userID: userID, activityIndicatorView: activityIndicatorView)
        }
        
    }
    
    
}

// MARK: - LoadOKDelegate,EditOKDelegate
extension DetailMyselfViewController:LoadOKDelegate,EditOKDelegate{
    
    //自分の明細を取得完了
    func loadMonthDetails_OK() {
        monthMyDetailsSets = loadDBModel.monthMyDetailsSets
        loadDBModel.loadUserInfo(userID: userID, activityIndicatorView: activityIndicatorView)
    }
    
    //自分のユーザーネーム、プロフィール画像を取得完了
    func loadUserInfo_OK(userName: String, profileImage: String, email: String, password: String) {
        self.profileImage = profileImage
        self.userName = userName
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        activityIndicatorView.stopAnimating()
    }
    
}

// MARK: - TableView

extension DetailMyselfViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("****numberOfRowsInSection****")
        print(monthMyDetailsSets.count)
        return monthMyDetailsSets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath) as! DetailCell
        cell.profileImage.sd_setImage(with: URL(string: profileImage), completed: nil)
        print("****cellForRowAt****")
        print(monthMyDetailsSets.count)
        cell.paymentLabel.text = changeCommaModel.getComma(num: monthMyDetailsSets[indexPath.row].paymentAmount) + " 円"
        cell.userNameLabel.text = userName
        cell.dateLabel.text = monthMyDetailsSets[indexPath.row].paymentDay
        cell.category.text = monthMyDetailsSets[indexPath.row].category
        cell.productNameLabel.text = monthMyDetailsSets[indexPath.row].productName
        
        cell.view.layer.cornerRadius = 5
        //        cell.view.translatesAutoresizingMaskIntoConstraints = true
        cell.view.layer.masksToBounds = false
        cell.view.layer.shadowOffset = CGSize(width: 1, height: 3)
        cell.view.layer.shadowOpacity = 0.2
        cell.view.layer.shadowRadius = 3
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 削除のアクションを設定する
        
        let deleteAction = UIContextualAction(style: .destructive, title:"delete") { [self]
            (ctxAction, view, completionHandler) in
            self.indexPath = indexPath
            print("***trailingSwipeActionsConfigurationForRowAt***")
            print(self.indexPath)
            print(groupID)
            print(loadDBModel.monthMyDetailsSets)
            db.collection("paymentData").document(monthMyDetailsSets[indexPath.row].documentID).delete()
            monthMyDetailsSets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        // 削除ボタンのデザインを設定する
        let trashImage = UIImage(systemName: "trash.fill")?.withTintColor(UIColor.white , renderingMode: .alwaysTemplate)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        
        // スワイプでの削除を無効化して設定する
        let swipeAction = UISwipeActionsConfiguration(actions:[deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = false
        
        return swipeAction
    }
    
    
}
