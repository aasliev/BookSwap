//
//  TabBarViewController.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 11/30/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    // UITabBarDelegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        //item.title == "Home" ? FirebaseAuth.sharedFirebaseAuth.clearOtherUser() :
        print("Selected item: ", item.title)
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected view controller")
    }

}
