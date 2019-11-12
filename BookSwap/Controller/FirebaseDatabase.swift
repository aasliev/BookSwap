//
//  FirebaseClass.swift
//  BookSwap
//
//  Created by RV on 11/10/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Firebase

class FirebaseDatabase {
    
    let db = Firestore.firestore()
    let FRIENDS_COLLECTION = "Friends"
    let NAME = "Name"
    let NUMBER_OF_SWAPS = "Number of Swaps"
    let FRIEND_SINCE = "Friend Since"
    var numberOfFriends = 0
    
    func getFriendsData () {
        
    }
    //func addNewFriend(_ userEmail: String, _ name: String, _ todayDate: Date) {
    func addNewFriend(_ currentUserEmail: String,_ friendsEmail: String) {
        
        // Add a new document in collection "cities"
        db.collection(currentUserEmail).document(friendsEmail).setData([
            NUMBER_OF_SWAPS: 0,
            FRIEND_SINCE: Date.init()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func getNumberOfFriends (_ currentUser: String){
        
        db.collection(currentUser).getDocuments()
            {
                (querySnapshot, err) in
                
                if let err = err
                {
                    print("Error getting documents: \(err)");
                }
                else
                {
                    var count = 0
                    for document in querySnapshot!.documents {
                        count += 1
                        print("\(document.documentID) => \(document.data())");
                    }
                    self.numberOfFriends = count
                    print("Count = \(count)");
                }
        }
        
        //return numberOfFriends
    }
}
