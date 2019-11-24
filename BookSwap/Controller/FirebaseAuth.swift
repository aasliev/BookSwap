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
    }
    
    //Returns email of current user
    func getCurrentUserEmail() -> String? {
        return (authInstance.currentUser?.email)
        
    }
    
    //Sign out current user from Firebase Auth
    func signOutCurrentUser(){
        
        do {
            try self.authInstance.signOut()
            CoreDataClass.sharedCoreData.clearAllEntity()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    //Returns username of current user
    func getUserName()-> String {
        
        //username are stored as display name of Firebase Auth
        return (authInstance.currentUser?.displayName) ?? "User Name"
    }
    
    func resetPassword(email: String, viewController: UIViewController){
        authInstance.sendPasswordReset(withEmail: email) { (error) in
            
            if (error != nil) {
                if let errorMsg = AuthErrorCode(rawValue: error!._code){
                    
                    //Method inside additionalFunction class shows error
                    self.commonFunctions.showError(error: error, errorMsg: errorMsg, screen: viewController)
                }
            }
        }
    }
    
//    //Perform the sign in method
//    func signInToFirebaseAuth (email: String, password: String, screen: UIViewController) -> Bool {
//
//        var boolean: Bool = false
//        authInstance.signIn(withEmail: email, password: password) { (user, error) in
//
//            if (error != nil){
//                if let errorMsg = AuthErrorCode(rawValue: error!._code){
//
//                }
//                boolean = false
//            } else {
//                print("Log in Successful!")
//                boolean = true
//            }
//
//        }
//        
//        return boolean
//    }
    
    
}
