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
    
    //プロフィール画像送信
    func sendProfileImage(data:Data){
        let image = UIImage(data: data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("profileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        imageRef.putData(profileImage!, metadata: nil) { (mataData, error) in
            if error != nil{
                return
            }
            imageRef.downloadURL { (url, error) in
                if error != nil{
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "userImage")
                self.sendOKDelegate?.sendImage_OK(url: url!.absoluteString)
            }
        }
    }
    
    //グループ画像送信
    func sendGroupImage(data:Data){
        let image = UIImage(data: data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child("groupImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        imageRef.putData(profileImage!, metadata: nil) { (mataData, error) in
            if error != nil{
                return
            }
            imageRef.downloadURL { (url, error) in
                if error != nil{
                    return
                }
                UserDefaults.standard.setValue(url?.absoluteString, forKey: "groupImage")
                self.sendOKDelegate?.sendImage_OK(url: url!.absoluteString)
            }
        }
    }
}
