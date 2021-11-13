//
//  EditDBModel.swift
//  Kakeibo
//
//  Created by 都甲裕希 on 2021/11/04.
//

import Foundation
import Firebase
import FirebaseFirestore

@objc protocol EditOKDelegate {
    @objc optional func editGroupInfoDelete_OK()
    @objc optional func editMonthDetailsDelete_OK()
    //削除
//    @objc optional func editProfileImageChange_OK()
//    @objc optional func editUserNameChange_OK()
    @objc optional func editUserDelete_OK()
    //追加
    @objc optional func editUserDelete2_OK()
}

class EditDBModel{
    
    var editOKDelegate:EditOKDelegate?
    var db = Firestore.firestore()
    var monthMyDetailsSets:[MonthMyDetailsSets] = []
    let dateFormatter = DateFormatter()
    
    //変更
    //招待を受けているグループで拒否ボタンを押したときのロード
    func editGroupInfoDelete(groupID:String,userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("userManagement").document(userID).getDocument { (snapShot, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                var joinGroupDic = data["joinGroupDic"] as! Dictionary<String,Bool>
                joinGroupDic.removeValue(forKey: groupID)
                self.db.collection("userManagement").document(userID).updateData(["joinGroupDic" : joinGroupDic])
                self.editOKDelegate?.editGroupInfoDelete_OK?()
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //自分の明細を削除したときにロード
    func editMonthDetailsDelete(groupID:String,userID:String,startDate:Date,endDate:Date,index:Int,activityIndicatorView:UIActivityIndicatorView){
        db.collection(groupID).whereField("userID", isEqualTo: userID).whereField("paymentDay", isGreaterThan: startDate).whereField("paymentDay", isLessThanOrEqualTo: endDate).order(by: "paymentDay").getDocuments { (snapShot, error) in
            self.monthMyDetailsSets = []
            self.dateFormatter.dateFormat = "yyyy/MM/dd"
            self.dateFormatter.locale = Locale(identifier: "ja_JP")
            self.dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let snapShotDoc = snapShot?.documents{
                var count = 0
                for doc in snapShotDoc{
                    let data = doc.data()
                    let productName = data["productName"] as! String
                    let paymentAmount = data["paymentAmount"] as! Int
                    let timestamp = data["paymentDay"] as! Timestamp
                    let category = data["category"] as! String
                    let userID = data["userID"] as! String
                    let date = timestamp.dateValue()
                    let paymentDay = self.dateFormatter.string(from: date)
                    if count == index{
                        self.db.collection(groupID).document(doc.documentID).delete()
                    }else{
                        let myNewData = MonthMyDetailsSets(productName: productName, paymentAmount: paymentAmount, paymentDay: paymentDay, category: category, userID: userID)
                        self.monthMyDetailsSets.append(myNewData)
                    }
                    count = count + 1
                }
            }
            self.editOKDelegate?.editMonthDetailsDelete_OK?()
        }
    }
    
    //変更
    //ユーザーが退会したときのロード
    func editUserDelete(groupID:String,userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("groupManagement").document(groupID).getDocument { (snapShot, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
//                var count = 0
                var settlementDic = data["settlementDic"] as! Dictionary<String,Bool>
                var userIDArray = data["userIDArray"] as! Array<String>
                userIDArray.removeAll(where: {$0 == userID})
//                for ID in userIDArray{
//                    if ID == userID{
//                        userIDArray.remove(at: count)
//                    }
//                    count = count + 1
//                }
                settlementDic.removeValue(forKey: userID)
                self.db.collection("groupManagement").document(groupID).updateData(["settlementDic" : settlementDic,"userIDArray" : userIDArray])
                self.editOKDelegate?.editUserDelete_OK?()
            }
            activityIndicatorView.stopAnimating()
        }
    }
    
    //追加
    //ユーザーが退会したときのロード２
    func editUserDelete2(groupID:String,userID:String,activityIndicatorView:UIActivityIndicatorView){
        db.collection("userManagement").document(userID).getDocument { (snapShot, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            if let data = snapShot?.data(){
                var joinGroupDic = data["joinGroupDic"] as! Dictionary<String,Bool>
                joinGroupDic.removeValue(forKey: groupID)
                self.db.collection("userManagement").document(userID).updateData(["joinGroupDic" : joinGroupDic])
                self.editOKDelegate?.editUserDelete2_OK?()
            }
            activityIndicatorView.stopAnimating()
        }
    }
}
