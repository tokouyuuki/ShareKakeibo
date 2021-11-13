//
//  MonthlyDataViewController.swift
//  Kakeibo
//
//  Created by 近藤大伍 on 2021/10/15.
//

import UIKit
import Parchment

class MonthlyDataViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overAllVC = OverAllViewController()
        let utilityVC = UtilityViewController()
        let foodVC = FoodViewController()
        let othersVC = OthersViewController()
        
        overAllVC.title = "全体"
        utilityVC.title = "光熱費"
        foodVC.title = "食費"
        othersVC.title = "その他"
        
        let pagingVC = PagingViewController(viewControllers: [
            overAllVC,
            utilityVC,
            foodVC,
            othersVC
        ])
     
        self.addChild(pagingVC)
        self.view.addSubview(pagingVC.view)
        pagingVC.didMove(toParent: self)
        pagingVC.view.translatesAutoresizingMaskIntoConstraints = false
        pagingVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pagingVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pagingVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pagingVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        pagingVC.selectedBackgroundColor = .clear
        pagingVC.indicatorColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        pagingVC.textColor = .darkGray
        pagingVC.selectedTextColor = UIColor(red: 255 / 255, green: 190 / 255, blue: 115 / 255, alpha: 1.0)
        pagingVC.menuBackgroundColor = .clear
        pagingVC.borderColor = .clear
        pagingVC.menuItemSize = .selfSizing(estimatedWidth: 80, height: 40)
        pagingVC.menuItemSpacing = 10
        pagingVC.menuHorizontalAlignment = .center
        
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
