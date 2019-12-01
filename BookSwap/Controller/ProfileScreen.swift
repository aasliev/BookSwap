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
    
    //Firebase Authentication instance
    let firebaseAuth = Auth.auth()
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUserDetails()

//        FirebaseDatabase.init().getNumberOfFriends(usersEmail: ((Auth.auth().currentUser?.email)!)) { numberOfFriends in
//            print("Inside ProfileScreen Number Of Friends = \(numberOfFriends)")
//            self.tempNumberOfFriends.text = "\(numberOfFriends)"
//        }
        
    }
    
    
    func setUserDetails(){
        
        
        userNameLbl.text = (authInstance.getUserName())
        
//        databaseIstance.getUserName(usersEmail: authInstance.getCurrentUserEmail()!) { (userName) in
//            self.userNameLbl.text = userName
//        }
        
        
        databaseIstance.getRating(usersEmail: authInstance.getCurrentUserEmail()!) { (rating) in
            self.rating_numberOfSwaps.text = "Rating: \(rating)"
            
            //Updating Number of swps user has done
            self.databaseIstance.getNumberOfSwaps(usersEmail: self.authInstance.getCurrentUserEmail()!) { (numberOfSwaps) in
                self.rating_numberOfSwaps.text = "\((self.rating_numberOfSwaps.text)!) / Swaps: \(numberOfSwaps)"
                print("this is Swaps \(numberOfSwaps)")
            }
        }
        
        
        
        //rating_numberOfSwaps.text = "4.5 / 10"
        
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        //create UIAlert with yes/no option
        let alert = UIAlertController(title: "Sing out", message: "Do you want to sign out?", preferredStyle: .alert)
        
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
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
            
        }))
        
        
        
        
        self.present(alert, animated: true, completion: nil)

    }
    @IBAction func friendsBtnPressed(_ sender: Any) {
        
        //FirebaseDatabase.init().addNewFriend(currentUserEmail: (firebaseAuth.currentUser?.email)!,friendsEmail: "Friend 3")
        
    }
}
