//
//  ViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/08.
//

import UIKit
import Firebase
import FirebaseFirestore

class LoginViewController: UIViewController,LoginOKDelegate {
  

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorShow: UILabel!
    var activityIndicatorView = UIActivityIndicatorView()
    
    var loginModel = LoginModel()
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 5
        loginModel.loginOKDelegate = self
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        
        view.addSubview(activityIndicatorView)
    }

    func loginOK(userID: String) {
        if userID != nil{
            let ProfileVC = storyboard?.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
            ProfileVC.userID = userID
            UserDefaults.standard.setValue(userID, forKey: "userID")
            activityIndicatorView.stopAnimating()
            navigationController?.pushViewController(ProfileVC, animated: true)
        }
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        activityIndicatorView.startAnimating()
        loginModel.login(emailTextField: emailTextField, passwordTextField: passwordTextField, errorShowLabel: errorShow, activityIndicatorView: activityIndicatorView)
    }
    

}



