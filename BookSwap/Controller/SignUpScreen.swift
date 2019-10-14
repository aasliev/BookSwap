//
//  SignUpScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 10/12/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase

class SignUpScreen: UIViewController {

    //Labels and TextFields from Main.Storyboard
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        if (checkIfTextFieldIsEmpty() ){
            
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (user, error) in
                
                if error != nil {
                    print(error!)
                }
                    
                else{
                    //Success
                    print("Registration Successful!")
                    
                    self.performSegue(withIdentifier: "toProfileScreen", sender: self)
                }
            }
        }
        
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
            //textField.backgroundColor = UIColor.red
            return false
            
        }else{
            
            // Revert the changes made in if statment
            textField.backgroundColor = UIColor.white
            return true
            
        }
    }
    
    
    func checkPassword(_ pswd1: String,_ pswd2: String ) -> Bool{
    
        if (pswd1 == pswd2 && !(pswd1.isEmpty)){
            return true
        }
        
        return false
        
    }
    

}
