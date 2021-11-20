//
//  ProfileConfigurationViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol profileConfigurationVCDelegate {
    func delivery(value:[String])
}

class ProfileConfigurationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    
    //auth内のデータ更新のため追加しました＿山口
    var loginModel = LoginModel()
    let user = Auth.auth().currentUser
    var password = String()
    var email = String()
    var userInfoArray = [String]()
    var delivery:profileConfigurationVCDelegate?
    
    var editDBModel = EditDBModel()
    var db = Firestore.firestore()
    var userID = String()
    var receiveTitle = String()
    var receiveDataName = String()
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = receiveTitle
        textField.placeholder = receiveTitle
        saveButton.layer.cornerRadius = 5
        saveButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        saveButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        loginModel.loginOKDelegate = self
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        //変更
        if textField.text == ""{
            warningLabel.text = "必須入力です"
        }else if receiveDataName == "userName"{
            db.collection("userManagement").document(userID).updateData(["\(receiveDataName)" : "\(textField.text!)"])
            self.navigationController?.popViewController(animated: true)
        }else if receiveDataName == "password"{
            loginModel.updateUserDataOfPassword(passwordTextField: textField, errorShowLabel: warningLabel)
            self.navigationController?.popViewController(animated: true)
        }else if receiveDataName == "email"{
            loginModel.updateUserDataOfEmail(emailTextField: textField, errorShowLabel: warningLabel)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
// MARK: - LoginOKDelegate
extension ProfileConfigurationViewController: LoginOKDelegate{
    
    func upDateOK(value: String) {
        db.collection("userManagement").document(userID).updateData(["\(receiveDataName)" : "\(value)"])
        if receiveDataName == "userName"{
            userInfoArray[0] = textField.text!
        }else if receiveDataName == "email"{
            userInfoArray[1] = textField.text!
        }else if receiveDataName == "password"{
            userInfoArray[2] = textField.text!
        }
        textField.text = ""
        delivery?.delivery(value: userInfoArray)
        navigationController?.popViewController(animated: true)
    }
    
}
