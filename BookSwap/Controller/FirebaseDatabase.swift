//
//  FirebaseClass.swift
//  BookSwap
//
//  Created by RV on 11/10/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Firebase

class FirebaseDatabase {
    
    //MARK: Firestore Database Istance
    let db = Firestore.firestore()
    
    //MARK: Firestore Collection Names
    let USERS_MAIN_COLLECTIN = "Users"
    let FRIENDS_SUB_COLLECTION = "Friends"
    let OWNEDBOOK_SUB_COLLECTION = "OwnedBook"
    let WIHSHLIST_SUB_COLLECTION = "WishList"
    
    //MARK: Firestore Fields Names
    let USERNAME_FIELD = "UserName"
    let NUMBER_OF_SWAPS_FIELD = "NumberOfSwaps"
    let RATING_FIELD = "Rating"
    let BOOKNAME_FIELD = "BookName"
    let AUTHOR_FIELD = "Author"
    let BOOK_STATUS_FIELD = "BooksStatus"
    let FRIENDSEMAIL_FIELD = "FriendsEmail"
    let NUMBEROFFRIENDS_FIELD = "NumberOfFriends"
    
    var numberOfFriends = 0
    

    func getFriendsData () {
        
    }
    
    //MARK: Add Methods to Firestore
    //MARK: Adding New User to Firestore when user Sign Up
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
    
    
    //MARK: Adding Book to OwnedBook Collection
    func addToOwnedBook(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(OWNEDBOOK_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_STATUS_FIELD: true
            
        ]) { err in
            
            if let err = err {
                print("Error writing OwnedBook: \(err)")
            } else {
                print("OwnedBook is successfully written!")
            }
        }
    }
    
    
    //MARK: Adding Book to WishList
    func addToWishList(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(WIHSHLIST_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor
            
        ]) { err in
            
            if let err = err {
                print("Error writing WishList: \(err)")
            } else {
                print("WishList is successfully written!")
            }
        }
    }
    
    //MARK: Add New Friend
    func addNewFriend(currentUserEmail: String,friendsEmail: String) {
       
        var uN = ""
        
        getUserName(usersEmail: currentUserEmail) {
            userName in
            uN = userName
        }
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(FRIENDS_SUB_COLLECTION)").document(friendsEmail).setData([
            
            USERNAME_FIELD: uN,
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
    
    
    //MARK: Add Number of Swaps
    func incrementNumberOfSwaps(currentUserEmail: String,friendsEmail: String) {
        
        let ref = db.collection(USERS_MAIN_COLLECTIN).document(currentUserEmail).collection(FRIENDS_SUB_COLLECTION).document(friendsEmail) //self.db.collection("(\(self.USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(FRIENDS_SUB_COLLECTION)/").document(friendsEmail)
        
        // Incrememnt the NumberOfSwaps field by 1.
        ref.updateData([
            self.NUMBER_OF_SWAPS_FIELD: FieldValue.increment(Int64(1))
        ]){
            error in
            print("This is Increment Number of Swaps Error: \(error)")
        }
    }
    
    
    //MARK: Read Methods from Firestore
    //MARK: Get Number of Friends
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
    
    
    func getUserName(usersEmail: String, completion: @escaping (String)->()){
        
        db.collection(USERS_MAIN_COLLECTIN).document(usersEmail).getDocument { (document, error) in
            var userName = ""
            if let document = document, document.exists {
                userName = document.get(self.USERNAME_FIELD) as! String
                
                print("Username of Friends from Firestore: \(self.numberOfFriends )")
            } else {
                print("\(self.USERNAME_FIELD) field does not exist")
            }
            completion(userName)
        }
    }
    
    func getListOfFriends(usersEmail: String, completion: @escaping (Dictionary<String  , Any>)->()){
    //func getListOfFriends(usersEmail: String){
        
        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(FRIENDS_SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
            
            var dictionary : Dictionary<String, Any> = [:]
            
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                    dictionary[document.documentID] = document.data()
                }
            }
            completion(dictionary)
        }
    }


    
}


