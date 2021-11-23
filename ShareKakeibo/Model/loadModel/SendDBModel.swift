//
//  SendDBModel.swift
//  kakeibo
//
//  Created by 都甲裕希 on 2021/10/23.
//

import Foundation
import FirebaseStorage

protocol SendOKDelegate{
    func sendImage_OK(url:String)
}

class SendDBModel{
    
    var sendOKDelegate:SendOKDelegate?
    var profileStoregePath = String()
    var groupStoregePath = String()
    
    //プロフィール画像送信
    func sendProfileImage(data:Data,activityIndicatorView:UIActivityIndicatorView){
        let image = UIImage(data: data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("profileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        profileStoregePath = "\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg"
        UserDefaults.standard.setValue(profileStoregePath, forKey: "profileStoregePath")
        imageRef.putData(profileImage!, metadata: nil) { (mataData, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            imageRef.downloadURL { (url, error) in
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "userImage")
                self.sendOKDelegate?.sendImage_OK(url: url!.absoluteString)
            }
        }
    }
    
    //プロフィール画像変更
    func sendChangeProfileImage(data:Data,activityIndicatorView:UIActivityIndicatorView){
        let image = UIImage(data: data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        profileStoregePath = UserDefaults.standard.object(forKey: "storegePath") as! String
        let imageRef = Storage.storage().reference().child("profileImage").child(profileStoregePath)
        imageRef.putData(profileImage!, metadata: nil) { (mataData, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            imageRef.downloadURL { (url, error) in
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "userImage")
                self.sendOKDelegate?.sendImage_OK(url: url!.absoluteString)
            }
        }
    }
    
    //グループ画像送信
    func sendGroupImage(data:Data,activityIndicatorView:UIActivityIndicatorView){
        let image = UIImage(data: data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("groupImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        groupStoregePath = "\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg"
        UserDefaults.standard.setValue(groupStoregePath, forKey: "groupStoregePath")
        imageRef.putData(profileImage!, metadata: nil) { (mataData, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            imageRef.downloadURL { (url, error) in
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "groupImage")
                self.sendOKDelegate?.sendImage_OK(url: url!.absoluteString)
            }
        }
    }
    
    //グループ画像送信
    func sendChangeGroupImage(data:Data,activityIndicatorView:UIActivityIndicatorView){
        let image = UIImage(data: data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        groupStoregePath = UserDefaults.standard.object(forKey: "groupStoregePath") as! String
        let imageRef = Storage.storage().reference().child("groupImage").child(groupStoregePath)
        imageRef.putData(profileImage!, metadata: nil) { (mataData, error) in
            if error != nil{
                activityIndicatorView.stopAnimating()
                return
            }
            imageRef.downloadURL { (url, error) in
                if error != nil{
                    activityIndicatorView.stopAnimating()
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "groupImage")
                self.sendOKDelegate?.sendImage_OK(url: url!.absoluteString)
            }
        }
    }
    
}
