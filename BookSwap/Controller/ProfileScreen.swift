//
//  ProfileScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase

class ProfileScreen: UIViewController {

    
    @IBOutlet weak var userNameLbl: UILabel!
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUserDetails()
    }
    
    
    func setUserDetails(){
        
       //print("\n\n\n\n\(Auth.auth().currentUser?.displayName)\n\n\n\n")
        let userName : String  = (Auth.auth().currentUser?.displayName ?? "Username")
        
        userNameLbl.text = userName
        
//        if userName.isEmpty {
//            //Auth.auth().currentUser?.displayName is nil
//            //Add another page to let user enter an username again
//            userNameLbl.text = "Username"   }
//        else { userNameLbl.text = userName    }
        
    }
    
    
    @IBAction func signOutButton(_ sender: Any) {
        
        //create UIAlert with yes/no option
        let alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.navigationController?.navigationBar.isHidden = true;
            
            self.performSegue(withIdentifier: "unwindToHomeScreen", sender: self)
        
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)

    }
}
