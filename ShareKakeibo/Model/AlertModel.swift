//
//  AlertModel.swift
//  kakeiboApp
//
//  Created by nishimaru on 2021/10/19.
//  Copyright © 2021 nishimaru. All rights reserved.
//
import Foundation
import UIKit
import Firebase
import Photos
import FirebaseAuth

class AlertModel{
    
   //変更_山口
    var loginModel = LoginModel()
    
    func exitAlert(viewController:UIViewController){
        
        let db = Firestore.firestore()
        
        let aleat = UIAlertController(title: "本当に退会しますか？", message: "", preferredStyle: .alert)
        
        let exit = UIAlertAction(title: "退会", style: .default) { (action) in
          
            db.collection("email").document("roomID").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
        aleat.addAction(exit)
        
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (acrion) in
            
        }
        
        aleat.addAction(cancel)
        
        viewController.present(aleat, animated: true, completion: nil)
    }
    
   
    
    
    func satsueiAlert(viewController:UIViewController){
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            
            self.createImagePicker(sourceType: .camera, CreateImagePicker: viewController)
            
        }
        
        let album = UIAlertAction(title: "アルバムから選択", style: .default) { (action) in
            self.createImagePicker(sourceType: .photoLibrary, CreateImagePicker: viewController)
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (acrion) in
            
        }
        alert.addAction(cancel)
        alert.addAction(camera)
        alert.addAction(album)
        
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
    func createImagePicker(sourceType:UIImagePickerController.SourceType,CreateImagePicker:UIViewController){
        
        //インスタンスを作成
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = sourceType
        cameraPicker.allowsEditing = false
        cameraPicker.delegate = CreateImagePicker as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        CreateImagePicker.present(cameraPicker, animated: true, completion: nil)
        
    }
   
   
    
    //auth内データ更新のため変更_山口
    func passWordAlert(viewController:UIViewController,userInfo:[String]){
        
        let nilAlert = UIAlertController(title: "未入力です", message: "", preferredStyle: .alert)
        let alert = UIAlertController(title: "パスワードが違います", message: "", preferredStyle: .alert)
        let passWordAlert = UIAlertController(title: "パスワードを入力してください", message: "", preferredStyle: .alert)
        passWordAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "パスワード"
            textField.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        let password = userInfo[2]
        
        let OK = UIAlertAction(title: "OK", style: .default) { [self] (action) in
            guard let textfield = passWordAlert.textFields?.first else{
                return
            }
            
            if textfield.text == ""{
                viewController.present(nilAlert, animated: true, completion: nil)
            }
            
            if textfield.text != password{
                viewController.present(alert, animated: true, completion: nil)
            }else{
                loginModel.reauthentication(viewController: viewController,userInfoArray: userInfo)
//                viewController.performSegue(withIdentifier: "ProfileConfigurationVC", sender: nil)
            }
            
        }
        
        passWordAlert.addAction(OK)
        passWordAlert.addAction(cancelAction)
        alert.addAction(cancelAction)
        nilAlert.addAction(cancelAction)
        viewController.present(passWordAlert, animated: true, completion: nil)
        
        
    }
    
}
