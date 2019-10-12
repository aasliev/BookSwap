//
//  SignUpScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 10/12/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

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
        
        if (checkIfTextFieldIsEmpty() ){}
        
        print(checkPassword(passwordTextField.text!, confirmPasswordTextField.text!))
    }
    
    func checkIfTextFieldIsEmpty() -> Bool {
        
        let userNameCheckStatus = checkIfEmpty(userNameTextField)
        let emailCheckStatus =  checkIfEmpty(emailTextField)
        let passwordCheckStatus =  checkIfEmpty(passwordTextField)
        let confirmPasswordCheckStatus =  checkIfEmpty(confirmPasswordTextField)
        
        return userNameCheckStatus && emailCheckStatus && passwordCheckStatus && confirmPasswordCheckStatus
    }
    
    func checkIfEmpty(_ textField: UITextField) -> Bool{
        
        if textField.text!.isEmpty {
            //Making changes to inform user that text field is empty
            textField.backgroundColor = UIColor.red
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
