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
    
    let commonFunctions = CommonFunctions.sharedCommonFunction
    let progressBarInstance = SVProgressHUDClass.shared
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth

    //Labels and TextFields from signUp.Storyboard
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var userNameAdded = false
    var dataAddedIntoFirestore = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        self.moveScreenWithKeyboard()

    }
    
    func checkIfTextFieldIsEmpty() -> Bool {
        
        let userNameCheckStatus = commonFunctions.checkIfEmpty(userNameTextField, "User Name", screen: self)
        let emailCheckStatus =  commonFunctions.checkIfEmpty(emailTextField, "Email", screen: self)
        let passwordCheckStatus =  commonFunctions.checkIfEmpty(passwordTextField, "Password", screen: self)
        let confirmPasswordCheckStatus =  commonFunctions.checkIfEmpty(confirmPasswordTextField, "Confirm Password", screen: self)
        
        return userNameCheckStatus && emailCheckStatus && passwordCheckStatus && confirmPasswordCheckStatus
    }
    
    
    func checkPassword(_ pswd1: String,_ pswd2: String ) -> Bool{
        
        if (pswd1 == pswd2){
            return true
        }
        return false
        
    }
    
    
    func chechError(_ error: Error?){
        
        if error != nil {
            
            if let errorMsg = AuthErrorCode(rawValue: (error! as AnyObject).code){
                self.commonFunctions.showError(error: error, errorMsg: errorMsg, screen: self)
            }
        } else {
            self.databaseInstance.addNewUserToFirestore( userName: self.userNameTextField.text!, email: self.emailTextField.text!){ boolean in
                
                print("Completion called from firestore \(boolean)")
                if boolean {
                    self.dataAddedIntoFirestore = true
                    
                    //This waits untill username is added
                    if (self.userNameAdded) {
                        // get a reference to the app delegate
                        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                        
                        // call didFinishLaunchWithOptions, this will make HomeScreen as Root ViewController
                        //Take user to Home Screen (Log In Screen), where user can log in.
                        appDelegate?.applicationDidFinishLaunching(UIApplication.shared)
                        
                    }
                }
                }
            addUserNameAndPerformSegue()
        }
    }
    
    
    func addUserNameAndPerformSegue(){
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = self.userNameTextField.text!
        changeRequest?.commitChanges { (error) in
            
            if error == nil {
                
                self.userNameAdded = true
                //This waits untill data is added on firestore database
                if (self.dataAddedIntoFirestore) {
                    // get a reference to the app delegate
                    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                    
                    // call didFinishLaunchWithOptions, this will make HomeScreen as Root ViewController
                    //Take user to Home Screen (Log In Screen), where user can log in.
                    appDelegate?.applicationDidFinishLaunching(UIApplication.shared)
                    
                }
                
            } else {
                print("An error occured while adding username \(String(describing: error))")
            }
        }
        
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        //Showing Processing Screen
        progressBarInstance.displayProgressBar()
        
        if (checkIfTextFieldIsEmpty() ){                                                //text if the fields are empty
            if(!(checkPassword(passwordTextField.text!, confirmPasswordTextField.text!))){          //check if the pswds are matching
                self.commonFunctions.createUIalert("Passwords are not matching.", self)
                
            }
            else                    //if they are matching check the email, if it's valid
                {

                    //Show showing the processing screen
                    progressBarInstance.displayProgressBar()
                    
                    Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                        user, error in
                        
                        self.chechError(error)
                        self.progressBarInstance.dismissProgressBar()
                }
            }
            progressBarInstance.dismissProgressBar()
        }
    }
}
