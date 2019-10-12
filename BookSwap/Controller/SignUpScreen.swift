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
        
        if (checkIfEmpty(userNameTextField) && checkIfEmpty(emailTextField) && checkIfEmpty(passwordTextField) && checkIfEmpty(confirmPasswordTextField)){}
        
        print(checkPassword(passwordTextField.text!, confirmPasswordTextField.text!))
    }
    
    func checkIfTextFieldIsEmpty() -> Bool {
        
        checkIfEmpty(userNameTextField)
        checkIfEmpty(emailTextField)
        checkIfEmpty(passwordTextField)
        checkIfEmpty(confirmPasswordTextField)
        
        return true
    }
    
    func checkIfEmpty(_ textField: UITextField) -> Bool{
        
        if textField.text!.isEmpty {
            //change color of the text field to red to inform user
            textField.backgroundColor = UIColor.red
            return false
            
        }else{
            
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
