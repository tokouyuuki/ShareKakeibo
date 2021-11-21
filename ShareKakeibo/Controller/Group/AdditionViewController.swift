//
//  CollectionViewController.swift
//  shareKakeibo
//
//  Created by nishimaru on 2021/10/26.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import UIKit
import SDWebImage
import Firebase
import FirebaseFirestore
import FirebaseStorage


class AdditionViewController: UIViewController {

    
    @IBOutlet weak var invitationButton: UIButton!
    @IBOutlet weak var searchUserTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var loadDBModel = LoadDBModel()
    var selectedUserImageArray = [String]() //profile画像のURLが入る
    var userIDArray = [String]()
    var userNameArray = [String]()
//    var imageArray = ["person","person.fill","pencil","trash","person"]
    var userSearchSets = [UserSearchSets]()
    var db = Firestore.firestore()
    
    var activityIndicatorView = UIActivityIndicatorView()
    let nothingLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        invitationButton.layer.cornerRadius = 5
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
       
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.layer.masksToBounds = false
        tableView.isScrollEnabled = false
        tableView.layer.shadowOffset = CGSize(width: 0, height: 1)
        tableView.layer.shadowOpacity = 0.5
        tableView.layer.shadowRadius = 1
//        tableView.isHidden = true
        tableView.transform = CGAffineTransform(scaleX: 0, y: 0)
        loadDBModel.loadOKDelegate = self
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    
    @IBAction func invitationButton(_ sender: Any) {
        let groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        print(userIDArray)
        userIDArray.removeAll(where: {$0 == userID})
        print(userIDArray)
        
        for usersID in userIDArray{
            db.collection("userManagement").document(usersID).setData(["joinGroupDic":["\(groupID)": false]], merge: true)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchUserButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        nothingLabel.isHidden = true
        loadDBModel.loadUserSearch(email: searchUserTextField.text!, activityIndicatorView: activityIndicatorView)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
// MARK: - CollectionView
extension AdditionViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUserImageArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.profileImage.sd_setImage(with: URL(string: selectedUserImageArray[indexPath.row]), completed: nil)
        cell.userNameLabel.text = userNameArray[indexPath.row]
        cell.deleteButton!.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
        print("daigoitemAt")
        print(cell.deleteButton.tag)
        
        return cell
    }
    
    @objc func tapDeleteButton(_ sender:UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        print(indexPath?.row)
        selectedUserImageArray.remove(at: indexPath!.row)
        userIDArray.remove(at: indexPath!.row)
        collectionView.deleteItems(at: [IndexPath(item: indexPath!.row, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
}

// MARK: - TableView
extension AdditionViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSearchSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
         
        let profileImage = cell.contentView.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        profileImage.layer.cornerRadius = 30
        profileImage.sd_setImage(with: URL(string: userSearchSets[indexPath.row].profileImage), completed: nil)
        userNameLabel.text = userSearchSets[indexPath.row].userName
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath
        
        nothingLabel.isHidden = true
        selectedUserImageArray.append(userSearchSets[indexPath.row].profileImage)
        userIDArray.append(userSearchSets[indexPath.row].userID)
        userNameArray.append(userSearchSets[indexPath.row].userName)
        userSearchSets.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.transform = CGAffineTransform(scaleX: 0, y: 0)
            self.tableView.alpha = 0
        }, completion:  { _ in
            //               self.tableView.isHidden = true
        })
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
}

// MARK: - LoadOKDeegate
extension AdditionViewController:LoadOKDelegate{
    
    func loadUserSearch_OK() {
        
        self.userSearchSets = loadDBModel.userSearchSets
        if userSearchSets.count == 0{
            view.addSubview(nothingLabel)
            nothingLabel.isHidden = false
            nothingLabel.translatesAutoresizingMaskIntoConstraints = false
            nothingLabel.text = "検索結果がありません"
            nothingLabel.textAlignment = .center
            nothingLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
            nothingLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 50).isActive = true
            nothingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            nothingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
            tableView.reloadData()
            activityIndicatorView.stopAnimating()
        }else{
            nothingLabel.isHidden = true
            UIView.animate(withDuration: 0.1, animations: {
                self.tableView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.tableView.alpha = 1
            }, completion:  { _ in
    //            self.tableView.isHidden = false
                self.tableViewHeight.constant = CGFloat(self.userSearchSets.count * 74)
                self.tableView.reloadData()
                self.activityIndicatorView.stopAnimating()
            })
        }
    }
    
}
