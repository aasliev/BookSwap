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
    let coreDataInstance = CoreDataClass.sharedCoreData
    
    //Variable to keep track of user's profile
    var usersProfile : String?
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        //databaseIstance.addSwapReqestNotification(senderEmail: "Sender", receiversEmail: "rutvik48@gmail.com", bookName: "Book Name2", bookAuthor: "Book Author2")
        
        //databaseIstance.removeBookSwapRequestNotification(sendersEmail: "Sender", reciverEmail: "rutvik48@gmail.com", bookName: "Book Name", bookAuthor: "Book Author")
        
        print("This is checkif call: \(CoreDataClass.sharedCoreData.checkIfOwnedBookExist(bookName: "bOOk", bookAuthor: "author"))")

        //CoreDataClass.sharedCoreData.changeBookStatusAndHolder(bookName: "book", bookAuthor: "author", bookHolder: "newHolding", status: false)

        // Do any additional setup after loading the view.

        if (Reachability.isConnectedToNetwork()){
            setUserDetails()
            checkOtherUser()
        } else {
            CommonFunctions.sharedCommonFunction.createUIalert("Network Error", self)
            print("no internet connection")
        }
                
    }
    
    
    
    func setUserDetails(){
        
        //If usersProfile is not initialized, set it equal to curent user's email
        //usersProfile will be nil when app auto log in the current user
        if usersProfile == nil {
            usersProfile =  authInstance.getCurrentUserEmail()
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
            
            if (coreDataInstance.checkIfFriend(friendEmail: usersProfile!)) {
                signOutButton.title = "Unfriend"
            } else {
                signOutButton.title = "Add Friend"
            }
            
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
            authInstance.usersScreen = usersProfile!
        }
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        //create UIAlert with yes/no option
        let alert : UIAlertController
        
        if (!authInstance.isItOtherUsersPage(userEmail: usersProfile!)){
            alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        } else {
            if (coreDataInstance.checkIfFriend(friendEmail: usersProfile!)) {
                alert = UIAlertController(title: "Unfriend", message: "Do you want to Unfriend?", preferredStyle: .alert)
            }else {
                alert = UIAlertController(title: "Friend Request Sent!", message: "Friend Reqest has been sent. ", preferredStyle: .alert)
            }
            
        }
        
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            
            if (!self.authInstance.isItOtherUsersPage(userEmail: self.usersProfile!)) {
                // Sign Out the user from Firebase Auth
                
//                do {
//                    try self.firebaseAuth.signOut()
//                    //CoreDataClass.sharedCoreData.resetAllEntities()
//
//                } catch let signOutError as NSError {
//                    print ("Error signing out: %@", signOutError)
//                }
                self.authInstance.signOutCurrentUser()
                
                self.navigationController?.navigationBar.isHidden = true;
                
                // get a reference to the app delegate
                let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
                
                // call didFinishLaunchWithOptions ... why?
                appDelegate?.applicationDidFinishLaunching(UIApplication.shared)
                
                
                
                //self.performSegue(withIdentifier: "toHomeScreen", sender: self)
            } else {
                
                
                //hide the button once user press "Yes"
                self.signOutButton.isEnabled = false
                self.signOutButton.tintColor = UIColor.clear
                
                //Note: signOutButton text is changed to "Unfriend" if users are friend. Else it is "Add Friend"
                //Chrcking if users are friend, if true, unfriend will be performed
                if (self.coreDataInstance.checkIfFriend(friendEmail: self.usersProfile!)) {
                    //function call to unfriend the user
                    self.databaseIstance.removeFriend(friendsEmail: self.usersProfile!)
                    
                    //remove friend's name from Core Data
                    self.coreDataInstance.removeFriend(friendsEmail: self.usersProfile!)
                    
                } else {
                    //If not friends, friend request will be sent.
                    
                    //getting email of logged in user
                    let loggedInUserEmail = self.authInstance.getCurrentUserEmail()
                    
                    //Getting username of logged in user, which will be needed to send a friend request
                    self.databaseIstance.getUserName(usersEmail: loggedInUserEmail, completion: { (userName) in
                        
                        //Sending a friend request. 'usersProfile' holds email of user whoes profile is on the screen.
                        self.databaseIstance.addFriendReqestNotification(senderEmail: self.authInstance.getCurrentUserEmail(), sendersUserName: userName, receiversEmail: self.usersProfile!)
                    })
                }
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    @IBAction func friendsBtnPressed(_ sender: Any) {
        
        //FirebaseDatabase.init().addNewFriend(currentUserEmail: (firebaseAuth.currentUser?.email)!,friendsEmail: "Friend 3")
        
    }
}
