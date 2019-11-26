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
    
    let commonFunctions = CommonFunctions.sharedCommonFunction
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //databaseIstance.removeFriend(friendsEmail: "Smith@gmail.com")
    }
    
    
    @IBAction func logInBtnPressed(_ sender: Any) {
    
        if (checkIfTextFieldIsEmpty()){
            
            //SVProgressHUD.show()
            //Log in the user
            
            let firebaseAuth = Auth.auth()
            firebaseAuth.signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) { (user , error) in
                
                if (error != nil){
                    if let errorMsg = AuthErrorCode(rawValue: error!._code){
                        
                        //Method inside additionalFunction class shows error
                        self.commonFunctions.showError(error: error, errorMsg: errorMsg, screen: self)
                        
                    }
                } else{
                    print("Log in Successful!")
                    
                    CoreDataClass.sharedCoreData.updateCoreData()
                
                    self.performSegue(withIdentifier: "toProfileScreen",  sender: self)
                    
    
                    // SVProgressHUD.dismiss()
                }
            }
        } 
    }
    
    
    //Same as Sign Up Screen function.
    func checkIfTextFieldIsEmpty() -> Bool {
        
        let userNameCheckStatus = commonFunctions.checkIfEmpty(userNameTextField, "User Name", screen: self)
        let passwordCheckStatus =  commonFunctions.checkIfEmpty(passwordTextField, "Password", screen: self)
        
        return userNameCheckStatus && passwordCheckStatus
    }

    
    @IBAction func unwindToHomeScreen(_ sender: UIStoryboardSegue){}
    
}
