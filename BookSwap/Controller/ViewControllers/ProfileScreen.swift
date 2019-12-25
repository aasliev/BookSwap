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
    let progressBarInstance = SVProgressHUDClass.shared
    
    //Variable to keep track of user's profile
    var usersProfile : String?
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        progressBarInstance.displayProgressBar()
        

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
    
    override func viewDidAppear(_ animated: Bool) {
        //coreDataInstance.updateCoreData()
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
  self.progressBarInstance.dismissProgressBar()
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
        
        progressBarInstance.displayProgressBar()
        
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
        
        //Checking if it is not other user's profile screen.
        if (!authInstance.isItOtherUsersPage(userEmail: usersProfile!)){
            alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        
        } else {  //if it is other user's profile screen. Show following alerts
            
            //Checking if this other user is Friend of logged in user.
            if (coreDataInstance.checkIfFriend(friendEmail: usersProfile!)) {
                
                //if true, show this following alert
                alert = UIAlertController(title: "Unfriend", message: "Do you want to Unfriend?", preferredStyle: .alert)
        
            }else {
                
                //If user is not friend of logged in user, show following alert on screen
                alert = UIAlertController(title: "Friend Request Sent!", message: "Friend Reqest has been sent. ", preferredStyle: .alert)
            }
            
        }
        
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        
        //If user press 'yes', perform following functions
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
           //this is for user on his/her profile screen.  This if function perform sign out procces
            if (!self.authInstance.isItOtherUsersPage(userEmail: self.usersProfile!)) {
           
               self.performSignOut()
                
            } else {
                //These changes are for logged in user is on some other user's profile screen
                
                self.performChangesForOthersProfileScreen()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    //MARK: Perform Sign Out
    func performSignOut () {
        
        //This function call sign out user from Firebase Auth
        self.authInstance.signOutCurrentUser()
        
        self.coreDataInstance.resetAllEntities()
        
        self.navigationController?.navigationBar.isHidden = true;
        
        
        // get a reference to the app delegate
        let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
        
        // call didFinishLaunchWithOptions, this will make HomeScreen as Root ViewController
        //Take user to Home Screen (Log In Screen), where user can log in.
        appDelegate?.applicationDidFinishLaunching(UIApplication.shared)
        
    }
    
    
    //MARK: Unfriend or Send Friend Request Process
    
    //This method will be called when logged in user is on some other user's profile screen and
    //clicks on text signOutButton hold. Text will be 'Unfriend' if users are friends, 'Add Friend' otherwise
    func performChangesForOthersProfileScreen () {
        
        //hide the button once user press "Yes"
        self.signOutButton.isEnabled = false
        self.signOutButton.tintColor = UIColor.clear
        
        //Note: signOutButton text is changed to "Unfriend" if users are friend. Else it is "Add Friend"
        //Chrcking if users are friend, if true, unfriend will be performed
        if (self.coreDataInstance.checkIfFriend(friendEmail: self.usersProfile!)) {
            
            performUnfriendProcess ()
            
        } else {
            //If not friends, friend request will be sent.
            
            performSendFriendRequestProcess()
        }
        
    }

    //Merhod will be called from if statment "performChangesForOthersProfileScreen()"
    func performUnfriendProcess () {
        
        //function call to unfriend the user from Firestore data base
        self.databaseIstance.removeFriend(friendsEmail: self.usersProfile!)
        
        //remove friend's name from Core Data
        self.coreDataInstance.removeFriend(friendsEmail: self.usersProfile!)
        
    }
    
    //Merhod will be called from else statment "performChangesForOthersProfileScreen()"
    func performSendFriendRequestProcess () {
        
        //getting email of logged in user
        let loggedInUserEmail = self.authInstance.getCurrentUserEmail()
        
        //Getting username of logged in user, which will be needed to send a friend request
        self.databaseIstance.getUserName(usersEmail: loggedInUserEmail, completion: { (userName) in
            
            //Sending a friend request. 'usersProfile' holds email of user whoes profile is on the screen.
            self.databaseIstance.addFriendReqestNotification(senderEmail: self.authInstance.getCurrentUserEmail(), sendersUserName: userName, receiversEmail: self.usersProfile!)
        })
        
    }
    
    
    @IBAction func friendsBtnPressed(_ sender: Any) {
        
        //FirebaseDatabase.init().addNewFriend(currentUserEmail: (firebaseAuth.currentUser?.email)!,friendsEmail: "Friend 3")
        
    }
}
