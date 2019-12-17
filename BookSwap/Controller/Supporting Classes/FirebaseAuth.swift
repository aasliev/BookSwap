//
//  FirebaseAuth.swift
//  BookSwap
//
//  Created by RV on 11/15/19.
//  Copyright © 2019 RV. All rights reserved.
//


import Firebase

class FirebaseAuth {
    
    let authInstance : Auth
    let commonFunctions : CommonFunctions
    private var currentUser : String
    var usersScreen  : String = ""
    
    static let sharedFirebaseAuth = FirebaseAuth()
    
    private init() {
        
        authInstance = Auth.auth()
        commonFunctions = CommonFunctions.sharedCommonFunction

        
        //checks if user is loged in. 
        currentUser = (authInstance.currentUser == nil) ? "" : (authInstance.currentUser?.email)!
        
    }
    
    //Returns email of current user
    func getCurrentUserEmail() -> String? {
        
        //currentUser will be equal to email of currently signed in user if
        //otherUser is nil. otherUser will be asigned email of other user's email
        if authInstance.currentUser != nil {
            currentUser = (authInstance.currentUser?.email)!
        } else {
            currentUser = ""
        }
        
//        //checking if otherUser holds email of logged in user
//        if (otherUser == (authInstance.currentUser?.email)) {
//            //if it is true change otherUser to 
//            otherUser = ""
//        }
        return currentUser
        
    }
    
    func getUsersScreen() -> String {
        return usersScreen
    }
    
    //Sign out current user from Firebase Auth
    func signOutCurrentUser(){
        
        do {
            try self.authInstance.signOut()
            
            //Reseting all data from Core Data of user 
            CoreDataClass.sharedCoreData.resetAllEntities()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    //Returns username of current user
    func getUserName()-> String {
        
        //username are stored as display name of Firebase Auth
        return (authInstance.currentUser?.displayName) ?? "User Name"
    }
    
    
    //This method sends email to reqested email address
    func resetPassword(email: String, viewController: UIViewController, completion: @escaping (Bool)->()) {
        authInstance.sendPasswordReset(withEmail: email) { (error) in
            
            //checks if email id exist into Firebase Auth
            if (error != nil) {
                if let errorMsg = AuthErrorCode(rawValue: error!._code){
                    
                    //Method inside additionalFunction class shows error
                    self.commonFunctions.showError(error: error, errorMsg: errorMsg, screen: viewController)
                }
                completion(false)
            }
            completion(true)
        }
    }
    
    
    //Checks if other user is empty
    func isItOtherUsersPage(userEmail : String) -> Bool {
        
        if userEmail == getCurrentUserEmail() {
            return false
        }
        
        return true
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
