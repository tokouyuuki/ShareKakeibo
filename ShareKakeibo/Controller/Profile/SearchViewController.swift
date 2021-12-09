//
//  CollectionViewController.swift
//  shareKakeibo
//
//  Created by nishimaru on 2021/10/26.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import UIKit
import SDWebImage

protocol CollectionDeligate {
    func SendArray(selectedUserImageArray:[String],userIDArray: [String],userNameArray: [String])
}

class SearchViewController: UIViewController {
    
    
    var collectionDeligate:CollectionDeligate?
    
    @IBOutlet weak var decideButton: UIButton!
    @IBOutlet weak var searchUserTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var loadDBModel = LoadDBModel()
    var selectedUserImageArray = [String]() //profile画像のURLが入る
    var userIDArray = [String]()
    var userNameArray = [String]()
    var userSearchSets = [UserSearchSets]()
    
    let nothingLabel = UILabel()
    
    var activityIndicatorView = UIActivityIndicatorView()
    var alertModel = AlertModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        decideButton.layer.cornerRadius = 5
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        loadDBModel.loadOKDelegate = self
        
        searchUserTextField.delegate = self
        
        view.addSubview(nothingLabel)
        nothingLabel.translatesAutoresizingMaskIntoConstraints = false
        nothingLabel.text = "検索結果がありません"
        nothingLabel.textAlignment = .center
        nothingLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        nothingLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 50).isActive = true
        nothingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nothingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nothingLabel.isHidden = true
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    @IBAction func decideButton(_ sender: Any) {
        collectionDeligate?.SendArray(selectedUserImageArray: selectedUserImageArray, userIDArray: userIDArray, userNameArray: userNameArray)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchUserButton(_ sender: Any) {
        if searchUserTextField.text == ""{
            nothingLabel.isHidden = false
            userSearchSets = []
            tableView.reloadData()
            return
        }
        activityIndicatorView.startAnimating()
        nothingLabel.isHidden = true
        loadDBModel.loadUserSearch(email: searchUserTextField.text!)
        searchUserTextField.text = ""
    }
    
    @IBAction func searchUserTextField(_ sender: Any) {
        if searchUserTextField.text == ""{
            nothingLabel.isHidden = false
            userSearchSets = []
            tableView.reloadData()
        }else{
            activityIndicatorView.startAnimating()
            nothingLabel.isHidden = true
            loadDBModel.loadUserSearch(email: searchUserTextField.text!)
        }
    }
    
    
}
// MARK: - CollectionView
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userIDArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.profileImage!.sd_setImage(with: URL(string: selectedUserImageArray[indexPath.row]), completed: nil)
        cell.deleteButton!.addTarget(self, action: #selector(tapDeleteButton(_:)), for: .touchUpInside)
        cell.userNameLabel.text = userNameArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    @objc func tapDeleteButton(_ sender:UIButton){
        let cell = sender.superview?.superview as! UICollectionViewCell
        let indexPath = collectionView.indexPath(for: cell)
        selectedUserImageArray.remove(at: indexPath!.row)
        userIDArray.remove(at: indexPath!.row)
        userNameArray.remove(at: indexPath!.row)
        collectionView.deleteItems(at: [IndexPath(item: indexPath!.row, section: 0)])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    
}

// MARK: - TableView
extension SearchViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userSearchSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let profileImage = cell.contentView.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        
        profileImage.sd_setImage(with: URL(string: userSearchSets[indexPath.row].profileImage), completed: nil)
        profileImage.layer.cornerRadius = 30
        userNameLabel.text = userSearchSets[indexPath.row].userName
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nothingLabel.isHidden = true
        selectedUserImageArray.append(userSearchSets[indexPath.row].profileImage)
        userIDArray.append(userSearchSets[indexPath.row].userID)
        userNameArray.append(userSearchSets[indexPath.row].userName)
        userSearchSets.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if userSearchSets.count == 0{
            nothingLabel.isHidden = false
        }
        collectionView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}

// MARK: - LoadOKDelegate
extension SearchViewController: LoadOKDelegate{
    
  
    func loadUserSearch_OK(check: Int) {
        if check == 0{
            activityIndicatorView.stopAnimating()
            alertModel.errorAlert(viewController: self)
        }else{
            var loadUserSearchSets = loadDBModel.userSearchSets
            for userID in userIDArray{
                loadUserSearchSets.removeAll(where: {$0.userID == userID})
            }
            let currentUserID = UserDefaults.standard.object(forKey: "userID") as! String
            loadUserSearchSets.removeAll { $0.userID == currentUserID}
            
            userSearchSets = loadUserSearchSets
            
            if userSearchSets.count == 0{
                nothingLabel.isHidden = false
                tableView.reloadData()
                activityIndicatorView.stopAnimating()
            }else{
                nothingLabel.isHidden = true
                tableView.reloadData()
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    
}

// MARK: - UITextFieldDelegate
extension SearchViewController:UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

