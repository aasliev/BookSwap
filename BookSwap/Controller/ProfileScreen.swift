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
        //var userName : String  = (Auth.auth().currentUser?.displayName!)!
        
        //userNameLbl.text = userName
        
    }
    
    
    @IBAction func signOutButton(_ sender: Any) {
        
        //create UIAlert with yes/no option
        let alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
        
            self.dismiss(animated: true, completion: nil)
            
            self.navigationController?.navigationBar.isHidden = true;
        
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        self.present(alert, animated: true, completion: nil)

    }
}
