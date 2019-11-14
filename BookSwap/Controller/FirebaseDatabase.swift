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
    let USERS_MAIN_COLLECTIN = "Users"
    let FRIENDS_SUB_COLLECTION = "Friends"
    let OWNEDBOOK_SUB_COLLECTION = "OwnedBook"
    let WHISHLIST_SUB_COLLECTION = "WhishList"
    let USERNAME_FIELD = "UserName"
    let NUMBER_OF_SWAPS_FIELD = "NumberOfSwaps"
    let RATING_FIELD = "Rating"
    //let BOOKNAME_FIELD = "BookName"
    let AUTHOR_FIELD = "Author"
    let BOOK_STATUS_FIELD = "BooksStatus"
    let FRIENDSEMAIL_FIELD = "FriendsEmail"
    let NUMBEROFFRIENDS_FIELD = "NumberOfFriends"
    var numberOfFriends = 0
    

    func getFriendsData () {
        
    }
    
    
    func addNewUserToFirestore(userName: String, email: String) {
        
        db.collection(USERS_MAIN_COLLECTIN).document(email).setData([
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
    
    
    func getNumberOfFriends(usersEmail: String, completion: @escaping (Int)->()) {
        
        db.collection(USERS_MAIN_COLLECTIN).document(usersEmail).getDocument { (document, error) in
            
            if let document = document, document.exists {
                self.numberOfFriends = document.get(self.NUMBEROFFRIENDS_FIELD)as! Int
            
                print("Number of Friends from Firestore: \(self.numberOfFriends )")
            } else {
                print("\(self.NUMBEROFFRIENDS_FIELD) field does not exist")
            }
            completion(self.numberOfFriends)
        }
    }
    
    
    
    func addNewOwnedBook(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(OWNEDBOOK_SUB_COLLECTION)").document(bookName).setData([
            
            //BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_STATUS_FIELD: true
            
        ]) { err in
            
            if let err = err {
                print("Error writing OwnedBool: \(err)")
            } else {
                print("OwnedBook is successfully written!")
            }
        }
    }
    
    
    func addNewFriend(currentUserEmail: String,friendsEmail: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(FRIENDS_SUB_COLLECTION)").document(friendsEmail).setData([
            
            FRIENDSEMAIL_FIELD: friendsEmail,
            NUMBER_OF_SWAPS_FIELD: 0
            
        ]) { err in
            
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
                
                let ref = self.db.collection(self.USERS_MAIN_COLLECTIN).document(currentUserEmail)
                
                // Atomically incrememnt the NumberOfFriends field by 1.
                ref.updateData([
                    self.NUMBEROFFRIENDS_FIELD: FieldValue.increment(Int64(1))
                    ])
            }
        }
    }
    
//    
//    func getNumberOfFriends (_ currentUser: String){
//        
////        db.collection(currentUser).getDocuments()
////            {
////                (querySnapshot, err) in
////
////                if let err = err
////                {
////                    print("Error getting documents: \(err)");
////                }
////                else
////                {
////                    var count = 0
////                    for document in querySnapshot!.documents {
////                        count += 1
////                        print("\(document.documentID) => \(document.data())");
////                    }
////                    self.numberOfFriends = count
////                    print("Count = \(count)");
////                }
////        }
////
////
////        //return numberOfFriends
//        
//            }
}


