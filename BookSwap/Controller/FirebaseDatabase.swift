//
//  FirebaseClass.swift
//  BookSwap
//
//  Created by RV on 11/10/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Firebase


class FirebaseDatabase {
    
    //Singleton
    static let shared = FirebaseDatabase()
    
    //MARK: Firestore Database Istance
    let sm = FirebaseApp.configure()
    let db = Firestore.firestore()
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    //MARK: Firestore Collection Names
    let USERS_MAIN_COLLECTIN = "Users"
    let FRIENDS_SUB_COLLECTION = "Friends"
    let OWNEDBOOK_SUB_COLLECTION = "OwnedBook"
    let WISHLIST_SUB_COLLECTION = "WishList"
    
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
    
    private init() {
    }

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
             _ = self.checkError(error: err, whileDoing: "adding new user to firebase")
        }
    }
    
    
    //MARK: Adding Book to OwnedBook Collection
    func addToOwnedBook(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(OWNEDBOOK_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_STATUS_FIELD: true
            
        ]) { err in
            
             _ = self.checkError(error: err, whileDoing: "adding book to OwnedBook")
        }
    }
    
    
    //MARK: Adding Book to WishList
    func addToWishList(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(WISHLIST_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding book to WishList")
        }
    }
    
    //MARK: Add New Friend
    func addNewFriend(currentUserEmail: String,friendsEmail: String, friendsUserName: String, recursion: Bool) {
       
        let ref = db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(FRIENDS_SUB_COLLECTION)").document(friendsEmail)
        
            ref.setData([
            
            USERNAME_FIELD: friendsUserName,
            FRIENDSEMAIL_FIELD: friendsEmail,
            NUMBER_OF_SWAPS_FIELD: 0
            
        ]) { err in
            
            if(self.checkError(error: err, whileDoing: "adding new friend") && recursion){
                self.addNewFriend(currentUserEmail: friendsEmail, friendsEmail: currentUserEmail, friendsUserName: self.authInstance.getUserName(), recursion: false)
            }
        }
    }
    
    
    //MARK: Add Number of Swaps
    func incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: String,friendsEmail: String, recursion: Bool) {
        
        let ref = db.collection(USERS_MAIN_COLLECTIN).document(currentUserEmail)
        
        incrementNumberOfSwapsInUserCollection(currentUserEmail: currentUserEmail, ref: ref)
        
        // Incrememnt the NumberOfSwaps field by 1.
        ref.collection(FRIENDS_SUB_COLLECTION).document(friendsEmail).updateData([
            self.NUMBER_OF_SWAPS_FIELD: FieldValue.increment(Int64(1))
        ]){
            error in
            if (self.checkError(error: error, whileDoing: "increasing number of swaps of friend") && recursion){
                
                //increasing number swaps in friends database a well
                self.incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: friendsEmail, friendsEmail: currentUserEmail, recursion: false)
            }
        }
    }
    
    
    private func incrementNumberOfSwapsInUserCollection (currentUserEmail: String, ref: DocumentReference) {
        
        // Incrememnt the NumberOfFriends field by 1.
        ref.updateData([
            self.NUMBER_OF_SWAPS_FIELD: FieldValue.increment(Int64(1))
        ]) {
            error in
            _ = self.checkError(error: error, whileDoing: "increasing number of swaps of current user")
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
    
    
    //Method gets username of given email of a user
    func getUserName(usersEmail: String, completion: @escaping (String)->()){
        
        db.collection(USERS_MAIN_COLLECTIN).document(usersEmail).getDocument { (document, error) in
            var userName = ""
            if let document = document, document.exists {
                userName = document.get(self.USERNAME_FIELD) as! String
                
                print("Username of Friends from Firestore: \(userName )")
            } else {
                print("\(self.USERNAME_FIELD) field does not exist")
            }
            completion(userName)
        }
    }
    
    
    func getListOfFriends(usersEmail: String, completion: @escaping (Dictionary<String , Dictionary<String  , Any>>)->()){
    //func getListOfFriends(usersEmail: String){
        
        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(FRIENDS_SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
            
            var dictionary : Dictionary<String, Dictionary<String  , Any>> = [:]
            
            if (self.checkError(error: error , whileDoing: "getting list of friends")) {
                
                for document in querySnapshot!.documents {
                    dictionary[document.documentID] = document.data()
                }
            }
    
            completion(dictionary)
        }
    }
    
    
    //Get list of books from OwnedBook collection or WishList.
    func getListOfOwnedBookOrWishList(usersEmail: String, trueForOwnedBookFalseForWishList: Bool, completion: @escaping (Dictionary<Int  , Dictionary<String  , Any>>)->()){
        
        //If "trueForOwnedBookFalseForWishList" is true SUB_COLLECTION = OwnedBook,
        //if false SUB_COLLECTION = WishList
        let SUB_COLLECTION = (trueForOwnedBookFalseForWishList) ? OWNEDBOOK_SUB_COLLECTION : WISHLIST_SUB_COLLECTION
        
        //Users/"user'sEmail"/SubCollection
        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
            
            var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
            
            if (self.checkError(error: error , whileDoing: "getting books from \(SUB_COLLECTION)")) {
                
                var index = 0
                for document in querySnapshot!.documents {
                    dictionary[index] = document.data()
                    index += 1
                }
            }
            
            completion(dictionary)
        }
    }
    
    
    //MARK: Error
    func checkError (error: Error?, whileDoing: String) -> Bool{
        
        //ternary operator
        //(error == err) ? print("Number of Swaps for Current User is incremented.") : print("Error while \(whileDoing): \(String(describing: error))")
        
        if error?.localizedDescription == nil{
            print("Successful \(whileDoing)!")
            return true
        } else {
            print("Error while \(whileDoing) .: \(String(describing: error))")
            return false
        }
            
    }
    
    
}


