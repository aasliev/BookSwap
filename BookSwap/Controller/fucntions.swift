//
//  fucntions.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 10/15/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class additionalFunctions{

    func createUIalert(_ message : String, _ screen : UIViewController )
    {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(action)
    screen.present(alertController, animated: true, completion: nil)
    
    }
    
    
    
    func checkIfEmpty(_ textField: UITextField,_ paceholderText: String, screen: UIViewController) -> Bool{
        
        if textField.text!.isEmpty {
            //Making changes to inform user that text field is empty
            textField.attributedPlaceholder = NSAttributedString(string: paceholderText,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            createUIalert("Add missing information.", screen)
            
            //textField.backgroundColor = UIColor.red
            return false
            
        }else{
            
            // Revert the changes made in if statment
            textField.backgroundColor = UIColor.white
            return true
            
        }
    }
    
    func showError (error: Error?,errorMsg: AuthErrorCode,screen: UIViewController) {
        
        switch errorMsg {
        
        case .networkError:
            createUIalert("Network Error.", screen)
            break
        case .userNotFound:
            createUIalert("Email or Pasword is wrong", screen)
            break
        case .wrongPassword:
           createUIalert("Email or Pasword is wrong", screen)
            break
        case .tooManyRequests:
            createUIalert("too many request", screen)
            break
        case .invalidEmail:
            createUIalert("Invalid Email", screen)
            break
        case .emailAlreadyInUse:
            createUIalert("Email is already in use.", screen)
            break
        case .weakPassword:
            createUIalert("weak password", screen)
            break
        default:
            createUIalert("Error occured. Please try again.", screen)
        }
    }
    
}

