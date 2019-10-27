//
//  LaunchScreen.swift
//  BookSwap
//
//  Created by RV on 10/23/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase

class LaunchScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        performSegue(withIdentifier: "toProfileScreen", sender: self)
    }
    
    @IBAction func btnPressed(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        if (firebaseAuth.currentUser != nil){
            
            performSegue(withIdentifier: "toProfileScreen",  sender: self)
            
        } else {
            performSegue(withIdentifier: "toHomeScreen", sender: self)
        }
        
    }
    
    @IBAction func unwindToLaunchScreen(_ sender: UIStoryboardSegue){}
    
}
