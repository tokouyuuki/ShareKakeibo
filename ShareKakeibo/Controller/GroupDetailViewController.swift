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
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
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
