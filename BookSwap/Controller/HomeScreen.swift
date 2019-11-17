//
//  HomeScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class HomeScreen: UIViewController {
    
    let aFunctions = additionalFunctions()
    let databaseIstance = FirebaseDatabase.init()
    let authInstance = FirebaseAuth.init()

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        databaseIstance.getUserName(usersEmail: "pirova@mani.zha") { (userName) in
//            print("\n\n\n\nThis is user name: \(userName)")
//
//            databaseIstance.addNewFriend(currentUserEmail: authInstance.getCurrentUserEmail(), friendsEmail: "pirova@mani.zha", friendsUserName: userName, recursion: true)
//        }
        
//        FirebaseDatabase.init().addNewFriend(currentUserEmail: authInstance.getCurrentUserEmail(), friendsEmail: "pirova@mani.zha", friendsUserName: "Manizha Pirova", recursion: true)
//        FirebaseDatabase.init().incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: (Auth.auth().currentUser?.email)!, friendsEmail:"pirova@mani.zha", recursion: true)
//        FirebaseDatabase.init().getUserName(usersEmail: ((Auth.auth().currentUser?.email)!)) {userName in
//            print("\n\n\n\nThis is user name: \(userName)")
//        }
    }
    
    
    @IBAction func logInBtnPressed(_ sender: Any) {
    
        if (checkIfTextFieldIsEmpty()){
            
            //SVProgressHUD.show()
            //Log in the user
            
//            if (authInstance.signInToFirebaseAuth(email: userNameTextField.text!, password: passwordTextField.text!, screen: self)) {
//
//                self.performSegue(withIdentifier: "toProfileScreen",  sender: self)
//                // SVProgressHUD.dismiss()
//
//            }
            let firebaseAuth = Auth.auth()
            firebaseAuth.signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) { (user , error) in
                
                if (error != nil){
                    if let errorMsg = AuthErrorCode(rawValue: error!._code){
                        
                        //Method inside additionalFunction class shows error
                        self.aFunctions.showError(error: error, errorMsg: errorMsg, screen: self)
                        
                    }
                } else{
                    print("Log in Successful!")
                    
                    self.performSegue(withIdentifier: "toProfileScreen",  sender: self)
                    
                   // SVProgressHUD.dismiss()
                }
            }
        } 
    }
    
    
    //Same as Sign Up Screen function.
    func checkIfTextFieldIsEmpty() -> Bool {
        
        let userNameCheckStatus = aFunctions.checkIfEmpty(userNameTextField, "User Name", screen: self)
        let passwordCheckStatus =  aFunctions.checkIfEmpty(passwordTextField, "Password", screen: self)
        
        return userNameCheckStatus && passwordCheckStatus
    }

    
    @IBAction func unwindToHomeScreen(_ sender: UIStoryboardSegue){}
    
}
