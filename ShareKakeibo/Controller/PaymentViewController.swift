//
//  PaymentViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import FirebaseFirestore

class PaymentViewController: UIViewController,UITextFieldDelegate {

    
    @IBOutlet weak var paymentConfirmedButton: UIButton!
    @IBOutlet weak var paymentNameTextField: UITextField!
    @IBOutlet weak var paymentDayTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    var db = Firestore.firestore()
    var groupID = String()
    var userID = String()
    let dateFormatter = DateFormatter()
    var paymentDay = Date()
    var year = String()
    var month = String()
    var textFieldCalcArray = [Int]()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        priceTextField.delegate = self
        
        paymentConfirmedButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        paymentConfirmedButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        paymentConfirmedButton.layer.shadowOpacity = 0.5
        paymentConfirmedButton.layer.shadowRadius = 1
        paymentConfirmedButton.layer.cornerRadius = 5
        
        resetButton.layer.cornerRadius = 5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        priceLabel.text = ""
        
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.dateComponents([.year,.month], from: Date())
        year = String(date.year!)
        month = String(date.month!)
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
       
    }
    
    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        paymentConfirmedButton.layer.shadowOpacity = 0
        paymentConfirmedButton.layer.shadowRadius = 0
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        paymentConfirmedButton.layer.shadowOpacity = 0.5
        paymentConfirmedButton.layer.shadowRadius = 1
    }
    
    @IBAction func paymentConfirmedButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        paymentConfirmedButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        paymentConfirmedButton.layer.shadowOpacity = 0.5
        paymentConfirmedButton.layer.shadowRadius = 1
        
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        paymentDay = dateFormatter.date(from: "\(year)年\(month)月\(paymentDayTextField.text!)日")!
        
        if priceLabel.text?.isEmpty == false {
            db.collection(groupID).document().setData(["paymentAmount" : Int(priceLabel.text!)! as Int,"productName" : paymentNameTextField.text! as String,"paymentDay" : paymentDay as Date,"category" : categoryTextField.text! as String,"userID" : userID as String])
        }else{
            //空だった場合の処理をお願いします
            //ここに来たのは２回目です。elseの処理がわかりません。お願いします。
            //支払名、カテゴリなどが空だったらどうしましょうか。時間が無いので先進みます。
        }
        
    }
    
    @IBAction func resetButton(_ sender: Any) {
        priceTextField.text = ""
        priceLabel.text = ""
        textFieldCalcArray = []
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let num:Int = Int(textField.text!){
            textFieldCalcArray.append(num)
            print(num)
        }
        priceLabel.text = "\(textFieldCalcArray.reduce(0){ $0 + $1 })"
        textField.text = ""
        return true
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
