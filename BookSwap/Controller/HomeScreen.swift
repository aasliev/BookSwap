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
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FirebaseDatabase.init().addNewFriend(currentUserEmail: FirebaseAuth.init().getCurrentUserEmail(), friendsEmail: "pirova@mani.zha", recursion: true)
        FirebaseDatabase.init().incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: (Auth.auth().currentUser?.email)!, friendsEmail:"pirova@mani.zha", recursion: true)
        FirebaseDatabase.init().getUserName(usersEmail: ((Auth.auth().currentUser?.email)!)) {userName in
            print("\n\n\n\nThis is user name: \(userName)")
        }
    }
    
    
    @IBAction func logInBtnPressed(_ sender: Any) {
    
        if (checkIfTextFieldIsEmpty()){
            
            //SVProgressHUD.show()
            //Log in the user
            let firebaseAuth = Auth.auth()
            firebaseAuth.signIn(withEmail: userNameTextField.text!, password: passwordTextField.text!) { (user , error) in

                if (error != nil){
                    if let errorMsg = AuthErrorCode(rawValue: error!._code){
                        switch errorMsg{
                            case .networkError:
                                self.aFunctions.createUIalert("Network Error.", self)
                                break
                            case .userNotFound:
                                self.aFunctions.createUIalert("user not found", self)
                                break
                            case .wrongPassword:
                                self.aFunctions.createUIalert("wrong password", self)
                                break
                            case .tooManyRequests:
                                self.aFunctions.createUIalert("too many request", self)
                            default:
                                print("other")
                            
                            
                    }
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
        
        let userNameCheckStatus = checkIfEmpty(userNameTextField, "User Name")
        let passwordCheckStatus =  checkIfEmpty(passwordTextField, "Password")
        
        return userNameCheckStatus && passwordCheckStatus
    }
    
    
    func checkIfEmpty(_ textField: UITextField,_ paceholderText: String) -> Bool{
        
        if textField.text!.isEmpty {
            //Making changes to inform user that text field is empty
            textField.attributedPlaceholder = NSAttributedString(string: paceholderText,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            self.aFunctions.createUIalert("Add missing information.", self)
            
            //textField.backgroundColor = UIColor.red
            return false
            
        }else{
            
            // Revert the changes made in if statment
            textField.backgroundColor = UIColor.white
            return true
            
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toProfileScreen"{
//
//            let destinationScreen = segue.destination as! ProfileScreen
//
//            destinationScreen.userNameReciver = userNameLbl.text!
//
//        }
//    }
//
    @IBAction func unwindToHomeScreen(_ sender: UIStoryboardSegue){}
    
}
