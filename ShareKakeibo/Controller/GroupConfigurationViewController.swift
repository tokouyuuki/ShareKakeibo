//
//  GroupConfigurationViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import CropViewController
import Firebase
import FirebaseFirestore
import FirebaseStorage

class GroupConfigurationViewController: UIViewController,CropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SendOKDelegate{
    
    
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var settlementTextField: UITextField!
    @IBOutlet weak var changeGroupButton: UIButton!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    
    var sendDBModel = SendDBModel()
    var db = Firestore.firestore()
    var alertModel = AlertModel()
    var selectedUserImageArray = [String]()
    var groupID = String()
    
    var buttonAnimatedModel = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeGroupButton.layer.cornerRadius = 5
        changeGroupButton.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        changeGroupButton.addTarget(self, action: #selector(touchUpOutside(_:)), for: .touchUpOutside)
        
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
    }

    @objc func touchDown(_ sender:UIButton){
        buttonAnimatedModel.startAnimation(sender: sender)
    }
    
    @objc func touchUpOutside(_ sender:UIButton){
        buttonAnimatedModel.endAnimation(sender: sender)
    }
    
    @IBAction func changeGroupButton(_ sender: Any) {
        buttonAnimatedModel.endAnimation(sender: sender as! UIButton)
        if groupNameTextField.text == "" || settlementTextField.text == ""{
            warningLabel.text = "グループ名と決済日は必須入力です"
        }else{
            db.collection("groupManagement").document(groupID).updateData(
                ["groupName": groupNameTextField.text!,"settlementDay": settlementTextField.text!])
        }
        
        if groupImageView.image != nil{
            sendDBModel.sendOKDelegate = self
            let data = groupImageView.image?.jpegData(compressionQuality: 1.0)
            sendDBModel.sendGroupImage(data: data!)
        }
    }
    
    func sendImage_OK(url: String) {
        db.collection("groupManagement").document(groupID).updateData(
            ["groupImage": url])
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func groupImageView(_ sender: Any) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    @IBAction func groupImageViewButton(_ sender: Any) {
        alertModel.satsueiAlert(viewController: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[.originalImage] as? UIImage != nil{
            let pickerImage = info[.originalImage] as! UIImage
            let cropController = CropViewController(croppingStyle: .default, image: pickerImage)
        
            cropController.delegate = self
            cropController.customAspectRatio = groupImageView.frame.size
            //cropBoxのサイズを固定する。
            cropController.cropView.cropBoxResizeEnabled = false
            //pickerを閉じたら、cropControllerを表示する。
            picker.dismiss(animated: true) {
                self.present(cropController, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        //トリミング編集が終えたら、呼び出される。
        self.groupImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
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
