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
    
    //Variable to keep track of user's profile
    var usersProfile : String?
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        //databaseIstance.addSwapReqestNotification(senderEmail: "Sender", receiversEmail: "rutvik48@gmail.com", bookName: "Book Name2", bookAuthor: "Book Author2")
        
        //databaseIstance.removeBookSwapRequestNotification(sendersEmail: "Sender", reciverEmail: "rutvik48@gmail.com", bookName: "Book Name", bookAuthor: "Book Author")
        
        //print("This is checkif call: \(CoreDataClass.sharedCoreData.checkIfFriends(username: "rutvik48@gmail.com")))")

        // Do any additional setup after loading the view.

        setUserDetails()

        checkOtherUser()
        
    }
    
    
    
    func setUserDetails(){
        
        //If usersProfile is not initialized, set it equal to curent user's email
        //usersProfile will be nil when app auto log in the current user
        if usersProfile == nil {
            usersProfile =  authInstance.getCurrentUserEmail()!
        }
        
        databaseIstance.getUserName(usersEmail: usersProfile!) { (userName) in
            self.userNameLbl.text = "\(userName)"
        }
        
        
        databaseIstance.getRating(usersEmail: usersProfile!) { (rating) in
            
            if rating == -1 {
                self.rating_numberOfSwaps.text = "Error updating rating/swaps"
                return
                
            }
            self.rating_numberOfSwaps.text = "Rating: \(rating)"
            
            //Updating Number of swps user has done
            self.databaseIstance.getNumberOfSwaps(usersEmail: self.usersProfile!) { (numberOfSwaps) in
                self.rating_numberOfSwaps.text = "\((self.rating_numberOfSwaps.text)!) / Swaps: \(numberOfSwaps)"
            }
        }
  
    }
    
    
    func checkOtherUser() {
        
        if (authInstance.isItOtherUsersPage(userEmail: usersProfile!)) {
            
            signOutButton.title = "Unfriend"
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toFriendsList" {
            let destinationVC = segue.destination as! FriendListScreen
            destinationVC.usersFriendsList = usersProfile!
            
        } else if segue.identifier == "toBooksPageController" {
            
            let destinationVC = segue.destination as! booksPageViewController
            destinationVC.usersBookPage = usersProfile
            authInstance.usersScreen = usersProfile!
            
        } else if segue.identifier == "toHistoryPageController" {
            
            let destinationVC = segue.destination as! historyPageViewController
            destinationVC.usersHistory = usersProfile
        }
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        //create UIAlert with yes/no option
        let alert : UIAlertController
        
        if (!authInstance.isItOtherUsersPage(userEmail: usersProfile!)){
            alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Unfriend", message: "Do you want to delete users_email from your friend list?", preferredStyle: .alert)
        }
        
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            
            if (!self.authInstance.isItOtherUsersPage(userEmail: self.usersProfile!)) {
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
