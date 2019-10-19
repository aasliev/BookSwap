//
//  SignUpScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 10/12/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpScreen: UIViewController {
    let aFunctions = additionalFunctions()

    //Labels and TextFields from signUp.Storyboard
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func checkIfTextFieldIsEmpty() -> Bool {
        
        let userNameCheckStatus = checkIfEmpty(userNameTextField, "User Name")
        let emailCheckStatus =  checkIfEmpty(emailTextField, "Email")
        let passwordCheckStatus =  checkIfEmpty(passwordTextField, "Password")
        let confirmPasswordCheckStatus =  checkIfEmpty(confirmPasswordTextField, "Confirm Password")
        
        return userNameCheckStatus && emailCheckStatus && passwordCheckStatus && confirmPasswordCheckStatus
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
    
    
    func checkPassword(_ pswd1: String,_ pswd2: String ) -> Bool{
        
        if (pswd1 == pswd2){
            return true
        }
        return false
        
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        if (checkIfTextFieldIsEmpty() ){                                                //text if the fields are empty
            if(!(checkPassword(passwordTextField.text!, confirmPasswordTextField.text!))){          //check if the pswds are matching
                self.aFunctions.createUIalert("Passwords are not matching.", self)
            }
            else                    //if they are matching check the email, if it's valid
                {

            //SVProgressHUD.show()
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                user, error in
              
                //SVProgressHUD.dismiss()
              
              
                if error != nil {
                  
                    if let errorMsg = AuthErrorCode(rawValue: error!._code){
                        switch errorMsg{
                            case .networkError:
                                self.aFunctions.createUIalert("Network Error.", self)
                                break
                            case .invalidEmail:
                                self.aFunctions.createUIalert("Invalid Email", self)
                                //print("invalid email")
                                break
                            case .emailAlreadyInUse:
                                self.aFunctions.createUIalert("Email is already in use.", self)
                                //print("Email is already in use")
                                break
                            case .weakPassword:
                                self.aFunctions.createUIalert("weak password", self)
                                break
                            default :
                                self.aFunctions.createUIalert("Other.", self)
                                //print("other")
                        }
                            
                        }
                        
                    }
                else
                {
                    self.performSegue(withIdentifier: "toProfileScreen",  sender: self)
                }
    
                    //Show showing the processing screen
                    //SVProgressHUD.show()
                    
                }
            }
        }
    }
}
