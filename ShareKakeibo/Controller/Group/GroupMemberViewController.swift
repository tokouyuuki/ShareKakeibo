//
//  GroupMemberViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import FirebaseFirestore
import SDWebImage

class GroupMemberViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var db = Firestore.firestore()
    var loadDBModel = LoadDBModel()
    var groupID = String()
    var profileImageArray = [String]()
    var userNameArray = [String]()
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        loadDBModel.loadOKDelegate = self
        //変更
        loadDBModel.loadUserIDAndSettlementDic(groupID: groupID, activityIndicatorView: activityIndicatorView)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - LoadOKDelegate
extension GroupMemberViewController:LoadOKDelegate{
    //変更
    //userID取得完了
    func loadUserIDAndSettlementDic_OK(settlementDic: Dictionary<String, Bool>, userIDArray: [String]) {
        profileImageArray = []
        userNameArray = []
        //ユーザーネームとプロフィール画像取得完了
        loadDBModel.loadGroupMember(userIDArray: userIDArray) { [self] UserSets in
            profileImageArray.append(UserSets.profileImage)
            userNameArray.append(UserSets.userName)
            tableView.reloadData()
        }
    }
    
}

// MARK: - TableView
extension GroupMemberViewController:UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userNameArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cellView = cell.contentView.viewWithTag(1)
        let profileImage = cell.contentView.viewWithTag(2) as! UIImageView
        let userNameLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        profileImage.sd_setImage(with: URL(string: profileImageArray[indexPath.row]), completed: nil)
        profileImage.layer.cornerRadius = 30
    
        userNameLabel.text = userNameArray[indexPath.row]
        cellView!.layer.cornerRadius = 5
        cellView!.layer.masksToBounds = false
        cellView!.layer.cornerRadius = 5
        cellView!.layer.shadowOffset = CGSize(width: 1, height: 1)
        cellView!.layer.shadowOpacity = 0.2
        cellView!.layer.shadowRadius = 1
        
        return cell
    }

//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        // 削除のアクションを設定する
//        let deleteAction = UIContextualAction(style: .destructive, title:"delete") {
//            (ctxAction, view, completionHandler) in
//            self.userNameArray.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .automatic)
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
//    }
//    
}
