//
//  ForgotPasswordScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 11/23/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class ForgotPasswordScreen: UIViewController {

    
    @IBOutlet weak var emailTextField: UITextField!
    let commonFunctions = CommonFunctions.sharedCommonFunction
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        if (commonFunctions.checkIfEmpty(emailTextField, "Email", screen: self)) {
            
            authInstance.resetPassword(email: emailTextField.text!, viewController: self)
            
        }
    }
    
}
