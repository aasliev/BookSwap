//
//  ProfileScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase

class ProfileScreen: UIViewController {

    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var rating_numberOfSwaps: UILabel!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    
    //Firebase Authentication instance
    let firebaseAuth = Auth.auth()
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        databaseIstance.addNewFriend(currentUserEmail: authInstance.getCurrentUserEmail()!, friendsEmail: "rutvik48@gmail.com", friendsUserName: "RV")
        
        setUserDetails()

        checkOtherUser()
        
    }
    
    
    
    func setUserDetails(){
        
        
        //userNameLbl.text = (authInstance.getUserName())
        
        databaseIstance.getUserName(usersEmail: authInstance.getCurrentUserEmail()!) { (userName) in
            self.userNameLbl.text = userName
        }
        
        
        databaseIstance.getRating(usersEmail: authInstance.getCurrentUserEmail()!) { (rating) in
            self.rating_numberOfSwaps.text = "Rating: \(rating)"
            
            //Updating Number of swps user has done
            self.databaseIstance.getNumberOfSwaps(usersEmail: self.authInstance.getCurrentUserEmail()!) { (numberOfSwaps) in
                self.rating_numberOfSwaps.text = "\((self.rating_numberOfSwaps.text)!) / Swaps: \(numberOfSwaps)"
            }
        }
  
    }
    
    
    func checkOtherUser() {
        
        if (!authInstance.isOtherUserEmpty()) {
            
            signOutButton.title = "Unfriend"
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        //create UIAlert with yes/no option
        let alert : UIAlertController
        
        if (authInstance.isOtherUserEmpty()){
            alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Unfriend", message: "Do you want to delete users_email from your friend list?", preferredStyle: .alert)
        }
        
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            
            if (self.authInstance.isOtherUserEmpty()) {
                // Sign Out the user from Firebase Auth
                
                do {
                    try self.firebaseAuth.signOut()
                    //CoreDataClass.sharedCoreData.resetAllEntities()
                    
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                self.authInstance.signOutCurrentUser()
                
                self.navigationController?.navigationBar.isHidden = true;
                
                CoreDataClass.sharedCoreData.resetAllEntities()
                
                self.performSegue(withIdentifier: "toHomeScreen", sender: self)
            } else {
                
                //Note: signOutButton text is changed to "Unfriend"
                //hide the button once user press "Yes"
                self.signOutButton.isEnabled = false
                self.signOutButton.tintColor = UIColor.clear
                
                //function call to unfriend the user
                
                //remove friend's name from Core Data
                
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    @IBAction func friendsBtnPressed(_ sender: Any) {
        
        //FirebaseDatabase.init().addNewFriend(currentUserEmail: (firebaseAuth.currentUser?.email)!,friendsEmail: "Friend 3")
        
    }
}
