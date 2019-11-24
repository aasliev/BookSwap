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
    let config = FirebaseApp.configure()
    let db = Firestore.firestore()
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    //MARK: Firestore Collection Names
    let USERS_MAIN_COLLECTIN = "Users"
    let FRIENDS_SUB_COLLECTION = "Friends"
    let OWNEDBOOK_SUB_COLLECTION = "OwnedBook"
    let WISHLIST_SUB_COLLECTION = "WishList"
    let HISTORY_SUB_COLLECTION = "History"
    
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
    //Adding New User to Firestore when user Sign Up
    func addNewUserToFirestore(userName: String, email: String) {
        
        db.collection(USERS_MAIN_COLLECTIN).document(email).setData([
            USERNAME_FIELD  : userName,
            NUMBER_OF_SWAPS_FIELD : 0,
            RATING_FIELD : 5.0])
        { err in
             _ = self.checkError(error: err, whileDoing: "adding new user to firebase")
        }
    }
    
    
    //Adding Book to OwnedBook Collection
    func addToOwnedBook(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(OWNEDBOOK_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_STATUS_FIELD: true
            
        ]) { err in
            
             _ = self.checkError(error: err, whileDoing: "adding book to OwnedBook")
        }
    }
    
    
    //Adding Book to WishList
    func addToWishList(currentUserEmail: String, bookName: String, bookAuthor: String) {
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(WISHLIST_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding book to WishList")
        }
    }
    
    //Add a New Friend
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
    
    
    //Method increments field "numberOfSwaps" by 1 inside Firestore: Users/currentUser/Friends/friendsEmail document
    func incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: String,friendsEmail: String, recursion: Bool) {
        
        let ref = db.collection(USERS_MAIN_COLLECTIN).document(currentUserEmail)
        
        //Incrementing number of swap field stored inside Firestore:Users/currentUser
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
    
    
    //Method increments field "numberOfSwaps" inside Firestore: Users/currentUser document
    private func incrementNumberOfSwapsInUserCollection (currentUserEmail: String, ref: DocumentReference) {
        
        // Incrememnt the NumberOfFriends field by 1.
        ref.updateData([
            self.NUMBER_OF_SWAPS_FIELD: FieldValue.increment(Int64(1))
        ]) {
            error in
            _ = self.checkError(error: error, whileDoing: "increasing number of swaps of current user")
        }
        
    }
    
    
    //MARK: Get Methods from Firestore
    //Get Number of Friends
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
    
    
    //MARK: Get Document
    //Get list of friends from Firestore: Users/currentUser/Friends/all Documents
    func getListOfFriends(usersEmail: String, completion: @escaping (Dictionary<String , Dictionary<String  , Any>>)->()){
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
    
    
    //Get history data from Firestore: Users/currentUser/History/friendsEmail/
    func getHistoryData (usersEmail: String, friendsEmail: String, completion: @escaping (Dictionary<Int  , Dictionary<String  , Any>>)->()){
        
        //Users/"user'sEmail"/SubCollection
        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(HISTORY_SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
            
            var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
            
            if (self.checkError(error: error , whileDoing: "getting history data from History Collection")) {
                
                var index = 0
                for document in querySnapshot!.documents {
                    dictionary[index] = document.data()
                    index += 1
                }
            }
            
            completion(dictionary)
        }
    }
    
    
    //MARK: Get Fields of Document
    //Gets the field of current user from Firestore: Users/currentUser/Document "Field"
    func getFieldData(usersEmail: String, fieldName: String, completion: @escaping (Any)->()) {
        
        
        db.collection(USERS_MAIN_COLLECTIN).document(usersEmail).getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let fieldData = document.get(fieldName)
                print("\(fieldName) : \(String(describing: fieldData) )")
                
                completion(fieldData as Any)
                
            } else {
                print("\(fieldName) field does not exist")
                completion(nanl)
            }
            //completion(userRating)
        }
    }
    
    //Method gets username of given email of a user
    func getUserName(usersEmail: String, completion: @escaping (String)->()){
        
        getFieldData(usersEmail: usersEmail, fieldName: USERNAME_FIELD) { userName in
            
            completion(userName as! String)
            
        }
    }
    
    //Gets rating of current user from Firestore: Users/currentUser/Document "Rating"
    func getRating(usersEmail: String, completion: @escaping (Int)->()) {
        
        getFieldData(usersEmail: usersEmail, fieldName: RATING_FIELD) { rating in
            
            completion(rating as! Int)
            
        }
    }
    
    //Gets rating of current user from Firestore: Users/currentUser/Document "NumberOfFriends"
    func getNumberOfSwaps(usersEmail: String, completion: @escaping (Int)->()) {
        
        getFieldData(usersEmail: usersEmail, fieldName: NUMBER_OF_SWAPS_FIELD) { swaps in
            
            completion(swaps as! Int)
            
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


