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
    
//    @IBAction func unwindToHomeScreen(_ unwindSegue: UIStoryboardSegue) {
//        let sourceViewController = unwindSegue.source
//        // Use data from the view controller which initiated the unwind segue
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
//        
//        databaseIstance.getListOfSearchFriends(usersEmail: authInstance.getCurrentUserEmail()!, searchText: "Mr. One") { (dict) in
//            print(dict as AnyObject)
//        }
        self.hideKeyboardWhenTappedAround()
        //self.moveScreenWithKeyboard()

        
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
                    
                    //This method updates the currentUser variable which keeps track of email of currently logged in user
                    self.authInstance.updateCurrentUser()
                
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

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func moveScreenWithKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height-70

            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
