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


class ProfileViewController: UIViewController,UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,LoadOKDelegate{
    
    
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!//roomNameが反映されるテーブルビューだよ
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileView: UIView! //profileImageViewの後ろの白いビュー
    @IBOutlet weak var profileOrangeView: UIView!//profileImageViewの後ろのオレンジのビュー
    @IBOutlet weak var newGroupCountLabel: UILabel!
    
    var loadDBModel = LoadDBModel()
    var userID = String()
    var groupID = String()
    //変更
    var groupJoinArray = [JoinGroupSets]()
    var newGroupCountArray = [JoinGroupSets]()
    
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
    
    func loadUserInfo_OK(userName: String, profileImage: String, email: String, password: String) {
        activityIndicatorView.stopAnimating()
        UserDefaults.standard.setValue(userName, forKey: "userName")
        UserDefaults.standard.setValue(profileImage, forKey: "profileImage")
        profileImageView.sd_setImage(with: URL(string: profileImage), completed: nil)
        userNameLabel.text = userName
        userInfoArray = [userName,email,password]
        //変更
        loadDBModel.loadUserJoinGroup(userID: userID)
        newGroupCountLabel.isHidden = true
    }
    
    //追加
    //どのグループに参加しているか招待されているかを取得完了
    func loadUserJoinGroup_OK(joinGroupDic: Dictionary<String, Bool>) {
        self.groupJoinArray = []
        self.newGroupCountArray = []
        //参加、不参加ごとにのグループの情報を取得完了
        loadDBModel.loadGroupInfo(joinGroupDic: joinGroupDic) { [self] JoinGroupSets in
            if JoinGroupSets.join == true{
                self.groupJoinArray.append(JoinGroupSets)
            }else if JoinGroupSets.join == false{
                self.newGroupCountArray.append(JoinGroupSets)
            }
            newGroupCountLabel.text = String(newGroupCountArray.count)
            if newGroupCountArray.count == 0{
                newGroupCountLabel.isHidden = true
            }else if newGroupCountArray.count < 10{
                newGroupCountLabel.isHidden = false
                newGroupCountLabel.text = String(newGroupCountArray.count)
            }else if newGroupCountArray.count >= 10{
                newGroupCountLabel.isHidden = false
                newGroupCountLabel.text = String(newGroupCountArray.count)
                newGroupCountLabel.frame.size = CGSize(width: 25, height: 20)
            }
            tableView.delegate = self
            tableView.dataSource = self
            tableView.reloadData()
        }
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
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
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
    
    @objc func swipeViewTap(_ sender:UITapGestureRecognizer){
        scrollToOriginal()
    }
    
    @IBAction func configurationButton(_ sender: Any) {
        scrollToPage()
    }
    
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
            cellView.layer.cornerRadius = 5
            cellView.layer.shadowOffset = CGSize(width: 1, height: 1)
            cellView.layer.shadowOpacity = 0.2
            cellView.layer.shadowRadius = 1
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 0{
            if indexPath.row == 0{
                let ProfileDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProfileDetailVC") as! ProfileDetailViewController
                ProfileDetailVC.userInfoArray = userInfoArray
                ProfileDetailVC.profileImageView.image = self.profileImageView.image
                navigationController?.pushViewController(ProfileDetailVC, animated: true)
                scrollToOriginal()
            }else if indexPath.row == 1{
                do {
                    try auth.signOut()
                    navigationController?.popViewController(animated: true)
                } catch let error {
                    //                    loginModel?.showError(error, showLabel: errorShow)
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
    
    
    @IBAction func notificationButton(_ sender: Any) {
        let notificationVC = storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationViewController
        navigationController?.pushViewController(notificationVC, animated: true)
    }
    
    @IBAction func newGroupButton(_ sender: Any) {
        let newGroupVC = storyboard?.instantiateViewController(withIdentifier: "NewGroupVC") as! NewGroupViewController
        navigationController?.pushViewController(newGroupVC, animated: true)
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
