//
//  FirebaseClass.swift
//  BookSwap
//
//  Created by RV on 11/10/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Firebase

class FirebaseDatabase {
    
    //let db = Firestore.firestore()
    let USERS_MAIN_COLLECTIN = "Users"
    let FRIENDS_SUB_COLLECTION = "Friends"
    let USERNAME_FIELD = "UserName"
    let NUMBER_OF_SWAPS_FIELD = "NumberOfSwaps"
    let RATING_FIELD = "Rating"
    let AUTHOR_FIELD = "Author"
    let BOOK_STATUS_FIELD = "BooksStatus"
    var numberOfFriends = 0
    
    func getFriendsData () {
        
    }
    
    
    func addNewUserToFirestore(userName: String, email: String) {
        
        let db1 = Firestore.firestore()
        db1.collection(USERS_MAIN_COLLECTIN).document(email).setData([
            USERNAME_FIELD  : userName,
            NUMBER_OF_SWAPS_FIELD : 0,
            RATING_FIELD : 5.0])
        { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
            
        }
    }
    
    
    
    //func addNewFriend(_ userEmail: String, _ name: String, _ todayDate: Date) {
    func addNewFriend(_ currentUserEmail: String,_ friendsEmail: String) {
        
        // Add a new document in collection "cities"
//        db.collection(currentUserEmail).document(friendsEmail).setData([
//            NUMBER_OF_SWAPS_FIELD: 0,
//            //FRIEND_SINCE: Date.init()
//        ]) { err in
//            if let err = err {
//                print("Error writing document: \(err)")
//            } else {
//                print("Document successfully written!")
//            }
//        }
    }
    
    func getNumberOfFriends (_ currentUser: String){
        
//        db.collection(currentUser).getDocuments()
//            {
//                (querySnapshot, err) in
//
//                if let err = err
//                {
//                    print("Error getting documents: \(err)");
//                }
//                else
//                {
//                    var count = 0
//                    for document in querySnapshot!.documents {
//                        count += 1
//                        print("\(document.documentID) => \(document.data())");
//                    }
//                    self.numberOfFriends = count
//                    print("Count = \(count)");
//                }
//        }
//
//
//        //return numberOfFriends
        
            }
}
