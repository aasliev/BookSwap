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
import CoreData

class CommonFunctions{
    
    static let sharedCommonFunction = CommonFunctions()
    let dataURL : URL = Bundle.main.url(forResource: "Data", withExtension: "plist")!
    let BOOK_ENTITY = "Book"
    let HISTORY_ENTITY = "History"
    private init() {
    }
    
    struct Data: Codable {
        var SVCounterHistory: Int
        var SVCounterBook: Int
        
        init(book: Int, history: Int){
            self.SVCounterBook = book
            self.SVCounterHistory = history
        }
    }
    
    
    //plist functions
    func getPlistData() -> Data{
        do {
            let path = Bundle.main.path(forResource: "Data", ofType: "plist")!
            let xml = FileManager.default.contents(atPath: path)!
            let decoder = PropertyListDecoder()
            let data = try? decoder.decode(Data.self, from: xml)
            return data as! Data
        } catch {
            //return 0
            print("Error getting plist value \(error)")
        }
    }
    
    func decrementData(entityName: String){
        var newData:Data?
        if entityName == BOOK_ENTITY{
            newData = Data(book: self.getPlistData().SVCounterBook-1, history: self.getPlistData().SVCounterHistory)
        }else {
            newData = Data(book: self.getPlistData().SVCounterBook, history: self.getPlistData().SVCounterHistory-1)
        }
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do{
            let data = try encoder.encode(newData)
            try data.write(to: self.dataURL)
        } catch {
            print("error decrementing Data.plist \(error)")
        }
    }
    
    
    func createUIalert(title : String = "Error", _ message : String, _ screen : UIViewController ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
            createUIalert("Email Not Found!", screen)
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

