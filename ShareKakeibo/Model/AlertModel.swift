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

class AlertModel{
    
   
    
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
   
   
    
    
    func passWordAlert(viewController:UIViewController,passWord:String){
        
        let nilAlert = UIAlertController(title: "未入力です", message: "", preferredStyle: .alert)
        let alert = UIAlertController(title: "パスワードが違います", message: "", preferredStyle: .alert)
        let passWordAlert = UIAlertController(title: "パスワードを入力してください", message: "", preferredStyle: .alert)
        passWordAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "パスワード"
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        let OK = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let textfield = passWordAlert.textFields?.first else{
                return
            }
            
            if textfield.text == ""{
                
                viewController.present(nilAlert, animated: true, completion: nil)
                
            }
            
            if textfield.text != passWord{
                viewController.present(alert, animated: true, completion: nil)
            }
            else{
                print(textfield.text)
                viewController.performSegue(withIdentifier: "ProfileConfigurationVC", sender: nil)
            }
            
        }
        
        passWordAlert.addAction(OK)
        passWordAlert.addAction(cancelAction)
        alert.addAction(cancelAction)
        nilAlert.addAction(cancelAction)
        viewController.present(passWordAlert, animated: true, completion: nil)
        
        
    }
    
}
