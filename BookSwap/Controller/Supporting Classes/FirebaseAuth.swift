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
    private var currentUser : String?
    var currentUserName : String?
    var usersScreen  : String = ""
    
    static let sharedFirebaseAuth = FirebaseAuth()
    
    private init() {
        
        authInstance = Auth.auth()
        commonFunctions = CommonFunctions.sharedCommonFunction

        
        //checks if user is loged in. 
        currentUser = (authInstance.currentUser == nil) ? "UserEmailMissing" : (authInstance.currentUser?.email)
        
    }
    
    
    //This method updates the currentUser variable which keeps track of email of currently logged in user
    func updateCurrentUser() {
        currentUser = (authInstance.currentUser == nil) ? "UserEmailMissing"  : (authInstance.currentUser?.email)
    }
    
    //Returns email of current user
    func getCurrentUserEmail() -> String {
        
        //currentUser will be equal to email of currently signed in user if
        return currentUser!
        
    }
    
    func getUsersScreen() -> String {
        return usersScreen
    }
    
    //Sign out current user from Firebase Auth
    func signOutCurrentUser(){
        
        do {
            try self.authInstance.signOut()
            
            //This method updates the currentUser variable which keeps track of email of currently logged in user
            updateCurrentUser()
            
            //Reseting all data from Core Data of user 
            CoreDataClass.sharedCoreData.resetAllEntities()
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    //Returns username of current user
    func getUserName()-> String {
        
        //username are stored as display name of Firebase Auth
        return (currentUserName) ?? "User Name"
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
