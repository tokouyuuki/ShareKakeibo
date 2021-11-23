//
//  ProfileViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import ViewAnimator
import SDWebImage
import Firebase
import FirebaseAuth


class ProfileViewController: UIViewController, UIGestureRecognizerDelegate{
    
    
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!//roomNameが反映されるテーブルビューだよ
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileView: UIView! //profileImageViewの後ろの白いビュー
    @IBOutlet weak var profileOrangeView: UIView!//profileImageViewの後ろのオレンジのビュー
    @IBOutlet weak var newGroupCountLabel: UILabel!
    @IBOutlet weak var notificationCountLabel: UILabel!
    
    var loadDBModel = LoadDBModel()
    var userID = String()
    var groupID = String()
    var groupJoinArray = [GroupSets]()
    var newGroupCountArray = [GroupSets]()
    
    var userInfoArray = [String]()
    var loginModel = LoginModel()
    var auth = Auth.auth()
    var activityIndicatorView = UIActivityIndicatorView()
    var originalNavigationControllerDelegate: UIGestureRecognizerDelegate?
    var configurationTableView = UITableView() //設定バーのテーブルビューだよ
    let configurationNameArray = ["プロフィールを変更","ログアウト"]
    let configurationImageArray = ["person.fill","exit"]
    let configurationLabel = UILabel()
    var swipeView = UIVisualEffectView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        profileImageView.layer.cornerRadius = 40
        profileView.layer.cornerRadius = 42
        profileOrangeView.layer.cornerRadius = 44
        
        configurationTableView.tag = 0
        configurationTableView.frame = CGRect(x: view.frame.size.width, y: 100, width: 260, height: scrollView.frame.height)
        configurationTableView.separatorStyle = .none
        configurationTableView.register(UINib(nibName: "ProfileConfigurationCell", bundle: nil), forCellReuseIdentifier: "ProfileConfigurationCell")
        configurationTableView.delegate = self
        configurationTableView.dataSource = self
        //        configurationTableView.isScrollEnabled = false
        
        tableView.separatorStyle = .none
        
        configurationLabel.text = "設定"
        configurationLabel.frame = CGRect(x: view.frame.size.width + 100, y: 50, width: 60, height: 35)
        configurationLabel.font = UIFont.boldSystemFont(ofSize: 28.0)
        configurationLabel.textColor = .darkGray
        
        swipeView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
        swipeView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        swipeView.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(swipeViewTap(_:)))
        swipeView.addGestureRecognizer(tapGesture)
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true //1ページずつスクロールする
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: view.frame.size.width + 260, height: view.frame.size.height)
        
        contentViewWidthConstraint.constant = view.frame.width + 260
        
        scrollView.addSubview(configurationTableView)
        scrollView.addSubview(configurationLabel)
        scrollView.addSubview(swipeView)
        scrollView.didMoveToSuperview()
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
        
        newGroupCountLabel.clipsToBounds = true
        newGroupCountLabel.layer.cornerRadius = 10
        
        notificationCountLabel.clipsToBounds = true
        notificationCountLabel.layer.cornerRadius = 10
        
        getFileNamesFromPreferences()
        
    }
    
    func getFileNamesFromPreferences() {
           // Libraryまでのファイルパスを取得
           let filePath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

           // filePathにPreferencesを追加
           let preferences = filePath.appendingPathComponent("Preferences")

           // Library/Preferences内のファイルのパスを取得
           guard let fileNames = try? FileManager.default.contentsOfDirectory(at: preferences, includingPropertiesForKeys: nil) else {
               return
           }
           // Library/Preferences内のファイル名を出力
           fileNames.compactMap { fileName in
               print(fileName.lastPathComponent)
           }
       }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // popGestureを乗っ取り、左スワイプでpopを無効化する
        // 必ずdisappearとセットで用いること
        if let popGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
            self.originalNavigationControllerDelegate = popGestureRecognizer.delegate
            popGestureRecognizer.delegate = self
        }
        
        let animation = [AnimationType.vector(CGVector(dx: 0, dy: 30))]
        UIView.animate(views: tableView.visibleCells, animations: animation, completion:nil)
        
        if let indexPath = tableView.indexPathForSelectedRow{
            tableView.deselectRow(at: indexPath, animated: true)
        }else if let congigurationIndexPath = configurationTableView.indexPathForSelectedRow {
            configurationTableView.deselectRow(at: congigurationIndexPath, animated: true)
        }
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        activityIndicatorView.startAnimating()
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadUserInfo(userID: userID, activityIndicatorView: activityIndicatorView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // popGestureを乗っ取り、左スワイプでpopを無効化する(のを解除する)
        // 必ずwillAppear/willDisappearとセットで用いること
        if let popGestureRecognizer = navigationController?.interactivePopGestureRecognizer {
            popGestureRecognizer.delegate = originalNavigationControllerDelegate
            originalNavigationControllerDelegate = nil
        }
    }
    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
    
    @objc func swipeViewTap(_ sender:UITapGestureRecognizer){
        scrollToOriginal()
    }
    
    @IBAction func configurationButton(_ sender: Any) {
        scrollToPage()
    }
    
    @IBAction func notificationButton(_ sender: Any) {
        let notificationVC = storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationViewController
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    @IBAction func newGroupButton(_ sender: Any) {
        let newGroupVC = storyboard?.instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupViewController
        navigationController?.pushViewController(newGroupVC, animated: true)
    }
    
    
}
//MARK:- LoadOKDelegate
extension ProfileViewController: LoadOKDelegate{
    
    func loadUserInfo_OK(userName: String, profileImage: String, email: String, password: String) {
        UserDefaults.standard.setValue(userName, forKey: "userName")
        UserDefaults.standard.setValue(profileImage, forKey: "profileImage")
        profileImageView.sd_setImage(with: URL(string: profileImage), completed: nil)
        userNameLabel.text = userName
        userInfoArray = [userName,email,password]
        loadDBModel.loadJoinGroup(groupID: groupID, userID: userID, activityIndicatorView: activityIndicatorView)
        newGroupCountLabel.isHidden = true
    }
    
    //参加しているグループの情報を取得完了
    func loadJoinGroup_OK() {
        groupJoinArray = loadDBModel.groupSets
        loadDBModel.loadNotJoinGroup(userID: userID, activityIndicatorView: activityIndicatorView)
    }
    
    //不参加のグループの数を取得完了
        func loadNotJoinGroup_OK(groupIDArray: [String], notJoinCount: Int) {
            print(notJoinCount)
            newGroupCountLabel.text = String(notJoinCount)
            if notJoinCount == 0{
                newGroupCountLabel.isHidden = true
            }else if notJoinCount < 10{
                newGroupCountLabel.isHidden = false
                newGroupCountLabel.text = String(notJoinCount)
            }else if notJoinCount >= 10{
                newGroupCountLabel.isHidden = false
                newGroupCountLabel.text = String(notJoinCount)
                newGroupCountLabel.frame.size = CGSize(width: 25, height: 20)
            }
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
            activityIndicatorView.stopAnimating()
        }
    
}

//MARK:- TableView
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0{
            return 2
        }else{
            return groupJoinArray.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView.tag == 0{
            return 1
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0{
            return 70
        }else{
            return 85
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0{
            let configurationCell = configurationTableView.dequeueReusableCell(withIdentifier: "ProfileConfigurationCell") as! ProfileConfigurationCell
            let configurationImageView = configurationCell.cellImageView
            let configurationLabel = configurationCell.label
            if indexPath.row == 0{
                configurationImageView!.image = UIImage(systemName: configurationImageArray[indexPath.row])
                configurationLabel?.text = configurationNameArray[indexPath.row]
            }else{
                configurationImageView!.image = UIImage(named: configurationImageArray[indexPath.row])
                configurationLabel?.text = configurationNameArray[indexPath.row]
            }
            return configurationCell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            let cellView = cell?.contentView.viewWithTag(1) as! UIView
            let groupImage = cell?.contentView.viewWithTag(2) as! UIImageView
            let groupNameLabel = cell?.contentView.viewWithTag(3) as! UILabel
            
            groupImage.layer.cornerRadius = 30
            groupImage.sd_setImage(with: URL(string: groupJoinArray[indexPath.row].groupImage), completed: nil)
            groupNameLabel.text = groupJoinArray[indexPath.row].groupName
            cellView.layer.cornerRadius = 5
            cellView.layer.masksToBounds = false
            cellView.layer.shadowOffset = CGSize(width: 1, height: 3)
            cellView.layer.shadowOpacity = 0.2
            cellView.layer.shadowRadius = 3
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0{
            if indexPath.row == 0{
                let ProfileDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProfileDetailVC") as! ProfileDetailViewController
                ProfileDetailVC.userInfoArray = userInfoArray
                ProfileDetailVC.profileImage = self.profileImageView.image!
                navigationController?.pushViewController(ProfileDetailVC, animated: true)
                scrollToOriginal()
            }else if indexPath.row == 1{
                do {
                    try auth.signOut()
                    UserDefaults.standard.removePersistentDomain(forName: "com.daigoSwift.Kakeibo.plist")
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
                    self.navigationController?.pushViewController(loginVC, animated: true)
                } catch let error {
                    print(error)
                    let alert = UIAlertController(title: "エラーです", message: "", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    present(alert, animated: true, completion: nil)
                }
            }
        }else{
            
            let tabBarContoller = storyboard?.instantiateViewController(withIdentifier: "TabBarContoller") as! UITabBarController
            navigationController?.pushViewController(tabBarContoller, animated: true)
            
            //この先ユーザーがどのルームを使うか認識したいのでroomIDを上書き保存する
            groupID = groupJoinArray[indexPath.row].groupID
            UserDefaults.standard.setValue(groupID, forKey: "groupID")
        }
    }
    
    
}

//MARK:- UIScrollViewDelegate
extension ProfileViewController: UIScrollViewDelegate{
    //スクロール中に呼ばれる
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 1{
            swipeView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            swipeView.alpha = (0.5 / 260) * scrollView.bounds.minX
            print("daigobounds")
            print(scrollView.bounds)
            print("daigoframe")
            print(scrollView.frame)
            print(scrollView.contentOffset.x)
        }
    }
    
    func scrollToPage() {
        var frame:CGRect = self.scrollView.frame
        frame.origin.x = 260
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    func scrollToOriginal(){
        var frame:CGRect = self.scrollView.frame
        frame.origin.x = 0
        self.scrollView.scrollRectToVisible(frame, animated: true)
    }
}
