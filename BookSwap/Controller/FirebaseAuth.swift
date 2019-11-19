//
//  FirebaseAuth.swift
//  BookSwap
//
//  Created by RV on 11/15/19.
//  Copyright © 2019 RV. All rights reserved.
//


import Firebase

class FirebaseAuth {
    
    let authInstance = Auth.auth()
    let commonFunctions = CommonFunctions.sharedCommonFunction
    
    static let sharedFirebaseAuth = FirebaseAuth()
    
    private init() {
        //FirebaseApp.configure()
    }
    
    func getCurrentUserEmail() -> String {
        return (authInstance.currentUser?.email)!
        
    }
    
    func getUserName()-> String {
        
        return (authInstance.currentUser?.displayName) ?? "User Name"
    }
    
    func signInToFirebaseAuth (email: String, password: String, screen: UIViewController) -> Bool {
        
        var boolean: Bool = false
        authInstance.signIn(withEmail: email, password: password) { (user, error) in
            
            if (error != nil){
                if let errorMsg = AuthErrorCode(rawValue: error!._code){
                    
                }
                boolean = false
            } else {
                print("Log in Successful!")
                boolean = true
            }
            
        }
        
        return boolean
    }
    
    
}
