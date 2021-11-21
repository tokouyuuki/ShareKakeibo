//
//  GroupDetailViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit

protocol GoToVcDelegate {
    func goToVC(segueID:String)
}

class GroupDetailViewController: UIViewController {

    var goToVcDelegate:GoToVcDelegate?
    var editDBModel = EditDBModel()
    
    var groupID = String()
    var userID = String()
    var activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editDBModel.editOKDelegate = self

        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .darkGray
        view.addSubview(activityIndicatorView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
                presentingViewController?.beginAppearanceTransition(false, animated: animated)
            }
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 13.0, *) {

            presentingViewController?.beginAppearanceTransition(true, animated: animated)
            presentingViewController?.endAppearanceTransition()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            presentingViewController?.endAppearanceTransition()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func groupConfigurationButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        goToVcDelegate?.goToVC(segueID: "GroupConfigurationVC")
    }
    
    @IBAction func memberButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        goToVcDelegate?.goToVC(segueID: "MemberVC")
    }
    
    @IBAction func invitationButton(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        goToVcDelegate?.goToVC(segueID: "AdditionVC")
    }
    
    @IBAction func exitButton(_ sender: Any) {
        groupID = UserDefaults.standard.object(forKey: "groupID") as! String
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        editDBModel.editUserDelete(groupID: groupID, userID: userID, activityIndicatorView: activityIndicatorView)
    }

}

// MARK: - EditOKDelegate

extension GroupDetailViewController: EditOKDelegate{
    
    func editUserDelete_OK() {
        editDBModel.editUserDelete2(groupID: groupID, userID: userID, activityIndicatorView: activityIndicatorView)
    }
    
    func editUserDelete2_OK() {
        dismiss(animated: true, completion: nil)        
        goToVcDelegate?.goToVC(segueID: "")
    }
    
}

