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
    //let config = FirebaseApp.configure()
    let db : Firestore
    let authInstance : FirebaseAuth
    
    //Singleton
    static let shared : FirebaseDatabase = FirebaseDatabase()
    
    //MARK: Firestore Collection Names
    let USERS_MAIN_COLLECTIN = "Users"
    let FRIENDS_SUB_COLLECTION = "Friends"
    let OWNEDBOOK_SUB_COLLECTION = "OwnedBook"
    let WISHLIST_SUB_COLLECTION = "WishList"
    let HISTORY_SUB_COLLECTION = "History"
    let HOLDINGS_SUB_COLLECTION = "HoldingBooks"
    let NOTIFICATION_SUB_COLLECTION = "Notification"
    
    //MARK: Firestore Fields Names
    let USER_EMAIL_FIELD = "Email"
    let USERNAME_FIELD = "UserName"
    let NUMBER_OF_SWAPS_FIELD = "NumberOfSwaps"
    let NUMBER_OF_HOLD_BOOKS = "NumberOfHoldingBooks"
    let RATING_FIELD = "Rating"
    let BOOKNAME_FIELD = "BookName"
    let AUTHOR_FIELD = "Author"
    let BOOK_STATUS_FIELD = "BooksStatus"
    let BOOK_HOLDER_FIELD = "BookHolder"
    let BOOK_OWNER_FIELD = "BookOwner"
    let FRIENDSEMAIL_FIELD = "FriendsEmail"
    let NUMBEROFFRIENDS_FIELD = "NumberOfFriends"
    let LOWERCASED_USERNAME_FIELD = "LowecasedUsername"
    let SENDERS_EMAIL_FIELD = "Sender"
    let SENDERS_USER_NAME_FIELD = "SendesUserName"
    let RECEIVERS_EMAIL_FIELD = "Receiver"
    let NOTIFICATION_TYPE = "Type"
    let RETURN_REQUESTED_FIELD = "ReturnRequested"
    let SWAP_IN_PROCESS = "SwapInProcess"
    let UPDATED_TO_COREDATA_FIELD = "UpdatedToCoreData"
    let TIMESTAMP = "Timestamp"
    
    //Notification Sub-Collections
    let BOOKSWAP_REQUEST_NOTIFICATION = "BookSwap"
    let FRIEND_REQUEST_NOTIFICATION = "Friend Request"
    let RETURN_BOOK_REQUEST_NOTIFICATION = "Returning Book"

    //MARK: Collection Paths
    let USER_COLLECTION_PATH : String
    
    //MARK: Collection Reference
    let USER_COLLECTION_REF : CollectionReference
    
    var path : String = ""
    var message : String = ""
    var ref : DocumentReference
    var numberOfHoldingBooks : Int?
    var rating : Int?
    private var numberOfSwaps : Int?
    let MAX_HOLDING_BOOKS = 5
    
    private init() {
        
        FirebaseApp.configure()
        
        db = Firestore.firestore()
        authInstance = FirebaseAuth.sharedFirebaseAuth
        
        USER_COLLECTION_REF = db.collection(USERS_MAIN_COLLECTIN)
        
        USER_COLLECTION_PATH = "\(USERS_MAIN_COLLECTIN)"
        
        //this exact ref won't be used. This is written to silent the error : "Return from initializer without initializing all stored properties"
        ref = db.collection("Document Path").document("Document Name")
        
    }

    func getFriendsData () {
    }
    
    //MARK: Add Methods to Firestore
    //Adding New User to Firestore when user Sign Up
    func addNewUserToFirestore(userName: String, email: String,completion: @escaping (Bool)->() ) {
        
        ref = db.collection(USERS_MAIN_COLLECTIN).document(email.lowercased())
        
        ref.setData([
            USER_EMAIL_FIELD: email.lowercased(),
            USERNAME_FIELD: userName,
            LOWERCASED_USERNAME_FIELD: userName.lowercased(),
            NUMBER_OF_SWAPS_FIELD: 0,
            RATING_FIELD: 5.0,
            NUMBEROFFRIENDS_FIELD: 0,
            NUMBER_OF_HOLD_BOOKS: 0])
        { err in
            
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)

            } else {
                print("Document successfully written!")
                completion(true)
            }
        }
    }
    
    
    //Adding Book to OwnedBook Collection
    func addToOwnedBook(currentUserEmail: String, bookName: String, bookAuthor: String) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(OWNEDBOOK_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        ref.setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_STATUS_FIELD: true,
            BOOK_HOLDER_FIELD: currentUserEmail
            
        ]) { err in
            
             _ = self.checkError(error: err, whileDoing: "adding book to OwnedBook")
        }
    }
    
    
    //Adding Book to WishList
    func addToWishList(currentUserEmail: String, bookName: String, bookAuthor: String) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(WISHLIST_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        ref.setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding book to WishList")
        }
    }
    
    
    //Add a New Friend
    func addNewFriend(currentUserEmail: String,friendsEmail: String, friendsUserName: String, recursion: Bool = true ) {
       
        path = "\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(FRIENDS_SUB_COLLECTION)"
        let ref = db.collection(path).document(friendsEmail)
        
            ref.setData([
            
            USERNAME_FIELD: friendsUserName,
            FRIENDSEMAIL_FIELD: friendsEmail,
            NUMBER_OF_SWAPS_FIELD: 0,
            //This field is used to check if data needs to be updated with CoreData.
                //Note: 'recursion' is true while adding data for logged in user, flase while adding data fro friend
            UPDATED_TO_COREDATA_FIELD : recursion
            
        ]) { err in
            
            if(self.checkError(error: err, whileDoing: "adding new friend")){
                self.increment_OR_DecrementNumberOfFriends(userEmail: currentUserEmail, by: 1)
                if(recursion) {
                    self.addNewFriend(currentUserEmail: friendsEmail, friendsEmail: currentUserEmail, friendsUserName: self.authInstance.getCurrentUserName(), recursion: false)
                    
                }
            }
        }
    }
    
    
    //This method is for moving from WishList to OwnedBook funtionality of the app
    func moveWishListToOwnedBook (currentUserEmail: String, bookName: String, bookAuthor: String) {
        
        //This function call will add new book into OwnedBook sub collection of FireStore
        addToOwnedBook(currentUserEmail: currentUserEmail, bookName: bookName, bookAuthor: bookAuthor)
        
        //This will remove book from WishList sub collection of FireStore
        removeWishListBook(bookName: bookName, bookAuthor: bookAuthor)
    }
    
    //Method will be called when user accepts a Book Swap request
    //Add book into Holding Sub Collection inside Firestore: Users/currentUser/Holdings/bookName-bookAuthor
    func addHoldingBookToPerformBookSwap (bookOwnerEmail: String, bookRequester : String, bookName: String, bookAuthor: String ) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(bookRequester)/\(HOLDINGS_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        ref.setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_OWNER_FIELD : bookOwnerEmail,
            RETURN_REQUESTED_FIELD : false,
            UPDATED_TO_COREDATA_FIELD: false
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding book to Holdings")
        }
        
        //Changing book holder's email, so user can keep track of who has the book, and changing book status
        changeBookHoldersEmail(bookOwnersEmail: bookOwnerEmail, bookReciversEmail: bookRequester, bookName: bookName, bookAuthor: bookAuthor, bookStatus: false)
        
        increment_OR_DecrementNumberOfHoldBook(userEmail: bookRequester, by: 1)
        
        addBookSwapHistory(reciversEmail: bookRequester, sendersEmail: bookOwnerEmail, bookName: bookName, bookAuthor: bookAuthor)

    }
    
    //This is function will be called by other Database functions to add a new field into a document
    private func addCoreDataUpdatedField (path: String, documentName: String, fieldStatus: Bool = false){
        
        db.collection(path).document(documentName).setData([
            UPDATED_TO_COREDATA_FIELD : false
        ], merge: true) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding \(self.UPDATED_TO_COREDATA_FIELD) field for \(self.authInstance.getCurrentUserEmail())")
        }
    }
    
    
    func addUpdateCoreDataRequestToBookshelf (userEmail: String, bookName: String, bookAuthor: String, fieldStatus: Bool = false) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(OWNEDBOOK_SUB_COLLECTION)"
        
        print("Path: \(path)\n /\(bookName)-\(bookAuthor)")
        addCoreDataUpdatedField(path: path, documentName: "\(bookName)-\(bookAuthor)", fieldStatus: fieldStatus)
    }
    
    //Method will add new field 'UpdatedCoreData' to a document inside History Sub-Collection.
//    func addUpdateCoreDataRequestToHistory(currentUsersEmail: String, sendersEmail: String, bookName: String, bookAuthor: String, fieldStatus: Bool = false) {
//
//        path = "\(USERS_MAIN_COLLECTIN)/\(currentUsersEmail)/\(HISTORY_SUB_COLLECTION)"
//        let docName = "\(sendersEmail)-\(bookName)-\(bookAuthor)"
//
//        addCoreDataUpdatedField(path: path, documentName: docName)
//    }
    
    //Method will add new field 'UpdatedToCoreData' to a document inside HoldingBooks Sub-Collection.
//    func addUpdateCoreDataRequestToHoldings (userEmail: String, bookName: String, bookAuthor: String, fieldStatus: Bool = false) {
//
//        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(HOLDINGS_SUB_COLLECTION)"
//
//        addCoreDataUpdatedField(path: path, documentName: "\(bookName)-\(bookAuthor)", fieldStatus: fieldStatus)
//
//    }
    
    //MARK: Add Notification Methods
    //Method to add swap reqest on Firestore: Users/reciver's user email/Notification/
    func addSwapReqestNotification (senderEmail: String, sendersUserName: String, receiversEmail : String, bookName : String ,bookAuthor :String) {
        
       path = "\(USERS_MAIN_COLLECTIN)/\(receiversEmail)/\(NOTIFICATION_SUB_COLLECTION)"
        ref = db.collection(path).document("\(senderEmail)-\(bookName)-\(bookAuthor)")
        
        ref.setData([
            
            SENDERS_EMAIL_FIELD : senderEmail,
            SENDERS_USER_NAME_FIELD : sendersUserName,
            BOOKNAME_FIELD : bookName,
            AUTHOR_FIELD : bookAuthor,
            NOTIFICATION_TYPE : BOOKSWAP_REQUEST_NOTIFICATION,
            TIMESTAMP : FieldValue.serverTimestamp()
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding book to Swap Request")
        }
    }
    
    
    //Method to add Friend reqest on Firestore: Users/reciver's user email/Notification/
    func addFriendReqestNotification (senderEmail: String, sendersUserName: String, receiversEmail : String) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(receiversEmail)/\(NOTIFICATION_SUB_COLLECTION)"
        ref = db.collection(path).document("\(senderEmail)-\(FRIEND_REQUEST_NOTIFICATION)")
            
        ref.setData([
            
            SENDERS_EMAIL_FIELD : senderEmail,
            SENDERS_USER_NAME_FIELD: sendersUserName,
            NOTIFICATION_TYPE : FRIEND_REQUEST_NOTIFICATION,
            TIMESTAMP : FieldValue.serverTimestamp()
        
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding Friend Request")
        }
    }
    
    //Method to add book return request notification
    func addReturnBookRequestNotification (reciversEmail : String, sendersEmail : String, sendersUserName: String, bookName: String, bookAuthor : String) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(reciversEmail)/\(NOTIFICATION_SUB_COLLECTION)"
        ref = db.collection(path).document("\(sendersEmail)-\(bookName)-\(bookAuthor)")
        
        ref.setData([
            
            SENDERS_EMAIL_FIELD : sendersEmail,
            BOOKNAME_FIELD : bookName,
            AUTHOR_FIELD : bookAuthor,
            SENDERS_USER_NAME_FIELD : sendersUserName,
            NOTIFICATION_TYPE : RETURN_BOOK_REQUEST_NOTIFICATION,
            TIMESTAMP : FieldValue.serverTimestamp()
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding Friend Request")
        }
        
        changeReturnRequestedFieldInHoldings(currentUser: sendersEmail, bookName: bookName, bookAuthor: bookAuthor, bookStatus: true)
        
    }
    
    
    //Method to add book return request notification
    func addBookSwapHistory (reciversEmail : String, sendersEmail : String, bookName: String, bookAuthor : String) {
        
        //History will for book swap will be added into both sender and reciver's collection on Firestore
        //index is used to run while loop twice.
        var index = 0
        //When index is 0, data will be added to reciver's collection
        var forCollectionOf = sendersEmail
        var status = true
        
        
        while index < 2 {
            //setting up connection for Firestore: Users/reciver's email/History/sender'semail-bookName-bookAuthor
            path = "\(USERS_MAIN_COLLECTIN)/\(forCollectionOf)/\(HISTORY_SUB_COLLECTION)"
            ref = db.collection(path).document("\(sendersEmail)-\(bookName)-\(bookAuthor)-\(reciversEmail)")
            
            ref.setData([
                
                SENDERS_EMAIL_FIELD : sendersEmail,
                RECEIVERS_EMAIL_FIELD : reciversEmail,
                BOOKNAME_FIELD : bookName,
                AUTHOR_FIELD : bookAuthor,
                SWAP_IN_PROCESS : true,
                TIMESTAMP : FieldValue.serverTimestamp(),
                UPDATED_TO_COREDATA_FIELD: status
                
            ]) { err in
                _ = self.checkError(error: err, whileDoing: "adding History Data")
            }
            
            index += 1
            status = false
            forCollectionOf = reciversEmail
        }
    }
    
    
    //MARK: Change Document Field Methods
    //changes book holder email, which will help user to keep track of book
    private func changeBookHoldersEmail(bookOwnersEmail : String, bookReciversEmail: String, bookName : String, bookAuthor : String, bookStatus : Bool) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(bookOwnersEmail)/\(OWNEDBOOK_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        // Set the BookHolder = email of logged in user
        ref.updateData([
            BOOK_HOLDER_FIELD: bookReciversEmail,
            BOOK_STATUS_FIELD : bookStatus
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "changing BookHolder's email.")
        }
        
        //Adding a field inside OwnedBook, Which Keeps stack of if data is updated to CoreData
        addUpdateCoreDataRequestToBookshelf(userEmail: bookOwnersEmail, bookName: bookName, bookAuthor: bookAuthor)
    }
    
    //changes book holder email, which will help user to keep track of book
    private func changeReturnRequestedFieldInHoldings (currentUser : String, bookName : String, bookAuthor : String, bookStatus : Bool) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(currentUser)/\(HOLDINGS_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        // Set the BookHolder = email of logged in user
        ref.updateData([
            RETURN_REQUESTED_FIELD : bookStatus
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "changing Return Requested of Holding books")
        }
    }
    
    
    //changes SwapInProcess field to false, which is used in History collection to check if swap is in process
    private func changeSwapInProcessToFalseInHistory (sendersEmail : String, reciversEmail : String, bookName : String, bookAuthor : String) {
        
        var index = 0
        var forCollectionOf = sendersEmail
        
        
        while (index < 2) {
            path = "\(USERS_MAIN_COLLECTIN)/\(forCollectionOf)/\(HISTORY_SUB_COLLECTION)"
            ref = db.collection(path).document("\(sendersEmail)-\(bookName)-\(bookAuthor)-\(reciversEmail)")
            
            print("path: \(path)\nref: \(ref)")
            ref.updateData([
                SWAP_IN_PROCESS : false,
                UPDATED_TO_COREDATA_FIELD: false
            ]) { err in
                
                _ = self.checkError(error: err, whileDoing: "changing SwapIProcess to false in History.")
            }
            
            index += 1
            forCollectionOf = reciversEmail
        }
        
    }
    
    
    //This method will be called when user confirms that he recived a book back from Notification
    func successfullyReturnedHoldingBook (reciversEmail : String, sendersEmail : String, bookName : String, bookAuthor : String) {
        
        //Changing the holder field inside Firestore: Users/currentUser's Email/OwnedBook/bookName-bookAuthor
        self.changeBookHoldersEmail(bookOwnersEmail: self.authInstance.getCurrentUserEmail(), bookReciversEmail: self.authInstance.getCurrentUserEmail(), bookName: bookName, bookAuthor: bookAuthor, bookStatus: true)
        
        //Removes the book book from holdingBooks
        removeBookFromHoldings(bookName: bookName, bookAuthor: bookAuthor, bookHolder: sendersEmail)
        
        //Updating the Swap In Process in History Sub-Collection
        self.changeSwapInProcessToFalseInHistory(sendersEmail: reciversEmail, reciversEmail: sendersEmail, bookName: bookName, bookAuthor: bookAuthor)
        
        //Decreasing number of book holding. Field "NumberOfHoldingBook" in Firestore: Users/currentUser
        increment_OR_DecrementNumberOfHoldBook(userEmail: sendersEmail, by: -1)

        incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: reciversEmail, friendsEmail: sendersEmail)
//       }
    }
    
    
    //MARK: Methods to Update CoreData Fields on Firestore
    
    //Will be called to update CoreData field status
    func changeUpdatedCoreDataStatusForOwnedBook(userEmail: String, bookName: String, bookAuthor: String, status: Bool){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(OWNEDBOOK_SUB_COLLECTION)"
        message = "in OwnedBook changing \(UPDATED_TO_COREDATA_FIELD) field to \(status)"
        
        // path = "\(USERS_MAIN_COLLECTIN)/\(forCollectionOf)/\(HISTORY_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        print("path: \(path)\nref: \(ref)")
        ref.updateData([
            UPDATED_TO_COREDATA_FIELD : status
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: self.message)
        }
        
        
    }
    
    //Will be called to update CoreData field status
    func changeUpdatedCoreDataStatusForHistory(usersEmail: String, sender: String, bookName: String, bookAuthor: String, reciver: String, status: Bool){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(HISTORY_SUB_COLLECTION)"
        message = "In History changing \(UPDATED_TO_COREDATA_FIELD) field to \(status)"
        
        // path = "\(USERS_MAIN_COLLECTIN)/\(forCollectionOf)/\(HISTORY_SUB_COLLECTION)"
        ref = db.collection(path).document("\(sender)-\(bookName)-\(bookAuthor)-\(reciver)")
        
        print("path: \(path)\nref: \(ref)")
        ref.updateData([
            UPDATED_TO_COREDATA_FIELD : status
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: self.message)
        }
    }

    
    
    //MARK: Increment Methods
    //Method increments field "numberOfSwaps" by 1 inside Firestore: Users/currentUser/Friends/friendsEmail document
    private func incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: String,friendsEmail: String, recursion: Bool = true) {
        
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
    
    
    //Method increments field "numberOfFriends" inside Firestore: Users/currentUser document
    private func increment_OR_DecrementNumberOfFriends (userEmail: String, by: Int) {
        
        let ref = db.collection(USERS_MAIN_COLLECTIN).document(userEmail)
        // Incrememnt the NumberOfFriends field by 1.
        ref.updateData([
            self.NUMBEROFFRIENDS_FIELD: FieldValue.increment(Int64(by))
        ]) {
            error in
            _ = self.checkError(error: error, whileDoing: "increasing or decreasing number of friends")
        }
        
    }
    
    //Method to increments field "numberOfHoldBook" inside Firestore: Users/currentUser document
    private func increment_OR_DecrementNumberOfHoldBook (userEmail: String, by: Int) {
        
        let ref = db.collection(USERS_MAIN_COLLECTIN).document(userEmail)
        // Incrememnt the NumberOfFriends field by 1.
        ref.updateData([
            self.NUMBER_OF_HOLD_BOOKS: FieldValue.increment(Int64(by))
        ]) {
            error in
            _ = self.checkError(error: error, whileDoing: "increasing or decreasing number of Holding Books")
        }
        
    }
    
    
    //MARK: Get All Document(s) inside
    //Search Friends
    func getListOfSearchFriends(usersEmail: String, searchText: String, completion: @escaping (Dictionary<String , Dictionary<String  , Any>>)->()){
        
        //NOTE: Because these searches are Asynchronous, search by Username is inside the closure of search by user's email.
        //Result of doing this, will get one dictionary of all documents.
        //First searching by user's Email
        db.collection(USERS_MAIN_COLLECTIN).whereField(USER_EMAIL_FIELD, isEqualTo: searchText.lowercased()).getDocuments { (querySnapshot, error) in
            
            var dictionary : Dictionary<String, Dictionary<String  , Any>> = [:]
            
            if (self.checkError(error: error , whileDoing: "getting list of friends")) {
                
                for document in querySnapshot!.documents {
                    dictionary[document.documentID] = document.data()
                }
            }
            
            //Once search by user's email is finished, this will search by username. To send combined dictionary [READ NOTE]
            self.db.collection(self.USERS_MAIN_COLLECTIN).whereField(self.LOWERCASED_USERNAME_FIELD, isEqualTo: searchText.lowercased()).getDocuments { (querySnapshot, error) in
                
                if (self.checkError(error: error , whileDoing: "getting list of friends")) {
                    
                    for document in querySnapshot!.documents {
                        dictionary[document.documentID] = document.data()
                    }
                }
                
                //Filter the search results. Removes informatiom of current user (if needed)
                dictionary.removeValue(forKey: self.authInstance.getCurrentUserEmail())
                
                completion(dictionary)
                
            }
        }
    }
    
    //Common method to get all documents from sub collections, will be called from other get methods
    private func getDocuments (docPath : String, docMessage : String, completion: @escaping (Dictionary<Int , Dictionary<String  , Any>>)->())  {
        
        var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
       // db.collection("Users").document("as@li.com").collection("Friends")
            db.collection(docPath).getDocuments { (querySnapshot, error) in
            
            if (self.checkError(error: error , whileDoing: docMessage)) {
                var index = 0
                for document in querySnapshot!.documents {
                    dictionary[index] = document.data()
                    //dictionary[document.documentID] = document.data()
                    index += 1
                }
            }
            
            completion(dictionary)
        }
        
    }
    
    
    //Get list of friends from Firestore: Users/currentUser/Friends/all Documents
    func getListOfFriends(usersEmail: String, completion: @escaping (Dictionary<Int , Dictionary<String  , Any>>)->()){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(FRIENDS_SUB_COLLECTION)"
        message = "getting list of friends"
        
        getDocuments(docPath: path, docMessage: message) { (friendListDictionary) in
            
            completion(friendListDictionary)
        }
//        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(FRIENDS_SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
//
//            var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
//
//            if (self.checkError(error: error , whileDoing: "getting list of friends")) {
//                var index = 0
//                for document in querySnapshot!.documents {
//                    dictionary[index] = document.data()
//                    //dictionary[document.documentID] = document.data()
//                    index += 1
//                }
//            }
//
//            completion(dictionary)
//        }
    }
    
    
    //Get list of books from OwnedBook collection or WishList.
    func getListOfOwnedBookOrWishList(usersEmail: String, trueForOwnedBookFalseForWishList: Bool, completion: @escaping (Dictionary<Int  , Dictionary<String  , Any>>)->()){
        
        //If "trueForOwnedBookFalseForWishList" is true SUB_COLLECTION = OwnedBook,
        //if false SUB_COLLECTION = WishList
        let SUB_COLLECTION = (trueForOwnedBookFalseForWishList) ? OWNEDBOOK_SUB_COLLECTION : WISHLIST_SUB_COLLECTION
        
        path = "\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(SUB_COLLECTION)"
        message = "getting books from \(SUB_COLLECTION)"
        
        getDocuments(docPath: path, docMessage: message) { (bookListDictionary) in
            
            completion(bookListDictionary)
        }
//
//        //Users/"user'sEmail"/SubCollection
//        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
//
//            var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
//
//            if (self.checkError(error: error , whileDoing: "getting books from \(SUB_COLLECTION)")) {
//
//                var index = 0
//                for document in querySnapshot!.documents {
//                    dictionary[index] = document.data()
//                    index += 1
//                }
//            }
//
//            completion(dictionary)
//        }
    }
    
    
    //Get history data from Firestore: Users/currentUser/History/friendsEmail/
    func getHistoryData (usersEmail: String, completion: @escaping (Dictionary<Int  , Dictionary<String  , Any>>)->()){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(HISTORY_SUB_COLLECTION)"
        message = "getting history data from History Collection"
        
        getDocuments(docPath: path, docMessage: message) { (historyDictionary) in
            
            completion(historyDictionary)
        }
        
        
//        //Users/"user'sEmail"/SubCollection
//        db.collection("\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(HISTORY_SUB_COLLECTION)").getDocuments { (querySnapshot, error) in
//
//            var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
//
//            if (self.checkError(error: error , whileDoing: "getting history data from History Collection")) {
//
//                var index = 0
//                for document in querySnapshot!.documents {
//                    dictionary[index] = document.data()
//                    index += 1
//                }
//            }
//
//            completion(dictionary)
//        }
    }
    
    //Method used to get all holding books from From Firestore:  Holding Books sub-collection
    func getHoldingBooks (usersEmail : String, completion: @escaping (Dictionary<Int  , Dictionary<String  , Any>>)->()) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(HOLDINGS_SUB_COLLECTION)"
        message = "getting data from Holding Books Collection"
        
        getDocuments(docPath: path, docMessage: message) { (holdingBookDictionary) in
            
            completion(holdingBookDictionary)
        }
        
    }
    
    
    //Method used to get all holding books from From Firestore:  Notification sub-collection
    func getNotifications (usersEmail : String, completion : @escaping (Dictionary<Int, Dictionary<String, Any>>)->()) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(usersEmail)/\(NOTIFICATION_SUB_COLLECTION)"
        message = "getting data from Notification Collection"
        
        getDocuments(docPath: path, docMessage: message) { (notificationDictionary) in
            
            completion(notificationDictionary)
        }
        
    }
    
    
    private func getListOfDocumentsNotAddedInCoreData(path: String, fieldStatus: Bool = false, message: String, completion : @escaping (Dictionary<Int , Dictionary<String  , Any>>)->()) {
        
        var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
        db.collection(path).whereField(UPDATED_TO_COREDATA_FIELD, isEqualTo: fieldStatus)
            .getDocuments() { (querySnapshot, err) in
                
                
                if (self.checkError(error: err , whileDoing: message)) {
                    var index = 0
                    for document in querySnapshot!.documents {
                        dictionary[index] = document.data()
                        index += 1
                    }
                }
                completion(dictionary)
        }
    }

    
    func getListofFriendsNotAddedInCoreData(userEmail: String, completion : @escaping (Dictionary<Int , Dictionary<String  , Any>>)->()){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(FRIENDS_SUB_COLLECTION)"
        message = "getting friends which is not in CoreData"
        
        getListOfDocumentsNotAddedInCoreData(path: path, message: message) { (dict) in
            completion(dict)
        }
//        var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
//        db.collection("\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(FRIENDS_SUB_COLLECTION)").whereField(UPDATED_TO_COREDATA_FIELD, isEqualTo: false)
//            .getDocuments() { (querySnapshot, err) in
//                if (self.checkError(error: err , whileDoing: "getting friends which is not in CoreData")) {
//                    var index = 0
//                    for document in querySnapshot!.documents {
//                        dictionary[index] = document.data()
//                        index += 1
//                    }
//                }
//            completion(dictionary)
//        }
    }
    
    
    func getListofHistoryNotAddedInCoreData(userEmail: String, completion : @escaping (Dictionary<Int , Dictionary<String  , Any>>)->()){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(HISTORY_SUB_COLLECTION)"
        message = "getting history which is not in CoreData"
        
        getListOfDocumentsNotAddedInCoreData(path: path, message: message) { (dict) in
            completion(dict)
        }
    }
    
    func getListofHoldingBooksNotAddedInCoreData(userEmail: String, completion : @escaping (Dictionary<Int , Dictionary<String  , Any>>)->()){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(HOLDINGS_SUB_COLLECTION)"
        message = "getting holding books which is not in CoreData"
        
        getListOfDocumentsNotAddedInCoreData(path: path, message: message) { (dict) in
            completion(dict)
        }
        
    }
    
    func getListofOwnedBookNotAddedInCoreData(userEmail: String, completion : @escaping (Dictionary<Int , Dictionary<String  , Any>>)->()){
        
        path = "\(USERS_MAIN_COLLECTIN)/\(userEmail)/\(OWNEDBOOK_SUB_COLLECTION)"
        message = "getting owned booka which is not in CoreData"
        
        getListOfDocumentsNotAddedInCoreData(path: path, message: message) { (dict) in
            completion(dict)
        }
        
    }
    
    //MARK: Get Field Data of a Document
    //Gets the field of current user from Firestore: Users/currentUser/Document "Field"
    private func getFieldData(usersEmail: String, fieldName: String, completion: @escaping (Any)->()) {
        
        
        db.collection(USERS_MAIN_COLLECTIN).document(usersEmail).getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let fieldData = document.get(fieldName)
                
                if (fieldData == nil ) {
                    completion(-1)
                } else {
                    completion(fieldData as Any)
                }
                
                
            } else {
                print("\(fieldName) field does not exist")
                completion(-1)
            }
            //completion(userRating)
        }
    }


    //Get Number of Friends
    func getNumberOfFriends(usersEmail: String, completion: @escaping (Int)->()) {
        
        getFieldData(usersEmail: usersEmail, fieldName: NUMBEROFFRIENDS_FIELD) { numberOfFriends in
            
            completion(numberOfFriends as! Int)
            
        }
    }
    
    
    //Method gets username of given email of a user
    func getUserName(usersEmail: String, completion: @escaping (String)->()){
        
        getFieldData(usersEmail: usersEmail, fieldName: USERNAME_FIELD) { uName in
                
                let userName : String
                userName = Int("\(uName)") == nil ? uName as! String : ""
                if (userName != ""){
                    completion(userName)
                } else {
                    if (self.authInstance.isItOtherUsersPage(userEmail: usersEmail)) {
                        completion("User Name")
                    } else {
                        completion(self.authInstance.getCurrentUserName())

                    }
                }
            }
    }
    
    //Gets rating of current user from Firestore: Users/currentUser/Document "Rating"
    func getRating(usersEmail: String, completion: @escaping (Double)->()) {
        
        if (rating == nil) {
            getFieldData(usersEmail: usersEmail.lowercased(), fieldName: RATING_FIELD){ rating in
                
                if ((rating as? Double != nil) && (rating as! Double != -1)){
                    self.rating = (rating as! Int)
                    completion(rating as! Double)
                } else {
                    completion(-1)
                }
            }
        } else {
            completion(Double(self.rating ?? -1))
        }
    }
    
    //Gets rating of current user from Firestore: Users/currentUser/Document "NumberOfSwaps"
    func getNumberOfSwaps(usersEmail: String, completion: @escaping (Int)->()) {
        
        if (self.numberOfSwaps == nil || authInstance.isItOtherUsersPage(userEmail: usersEmail)) {
            
            getFieldData(usersEmail: usersEmail, fieldName: NUMBER_OF_SWAPS_FIELD) { swaps in
                
                if ((swaps as? Int != nil) && (swaps as! Int != -1)){
                    self.numberOfSwaps = (swaps as! Int)
                    completion(swaps as! Int)
                } else {
                    completion(-1)
                }
            }
        } else {
            completion(self.numberOfSwaps ?? -1)
        }
    }
    
    //Get Number of Holding Books. Function is called inside init() of FirebaseDatabase
    func getNumberOfHoldingBooks(usersEmail: String, completion: @escaping (Int)->()) {
        
        //Checking if 'numberOfHoldingBooks' is nil, that means code inside if statment isn't performed yet.
        if (numberOfHoldingBooks == nil) {
            
            getFieldData(usersEmail: usersEmail, fieldName: NUMBER_OF_HOLD_BOOKS) { holdingBooks in
                
                //'holdingBooks' will be -1 if data wasn't found
                if (holdingBooks as! Int == -1){
                    //In that case, send number of hoding book equals to 0
                    completion(0)
                } else {
                    
                    //If data ws recived successfully, set it to 'numberOfHoldingBooks' for later use
                    self.numberOfHoldingBooks = (holdingBooks as! Int)
                    completion(holdingBooks as! Int)
                }
            }
        } else {
            completion(self.numberOfHoldingBooks!)
        }
    }
    
    //Returns Book owner's email which is stored inside Firestore: Users/Book holder's Email/Holdings/bookName-bookAuthor. Called by method successfullyReturnedHoldingBook
    private func getBookOwnerFromHoldings(bookName: String, bookAuthor: String, completion: @escaping (String)->()) {
        
        db.collection("\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail())/\(HOLDINGS_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let fieldData = document.get(self.BOOK_OWNER_FIELD)
                
                completion(fieldData as! String)
                
            } else {
                print("Book Owner field does not exist")
                completion("-1")
            }
        }
    }
    
    //Called by method successfullyReturnedHoldingBook
    private func getBookHoldersEmail(currentUser : String, bookName: String, bookAuthor: String, completion: @escaping (String)->()) {
        
        db.collection("\(USERS_MAIN_COLLECTIN)/\(currentUser)/\(OWNEDBOOK_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let fieldData = document.get(self.BOOK_HOLDER_FIELD)
                
                completion(fieldData as! String)
                
            } else {
                print("Book Holder field does not exist")
                completion("-1")
            }
        }
    }
    
    
    //MARK: Delete Document
    //Method to delete field
    private func deleteDocument(documentPath: String, documentName: String) {
        db.collection(documentPath).document(documentName).delete()
        
    }
    
    
    //Remove book from OwnedBook from Firestore: Users/currentUser/OwnedBook/Document "BookName-AuthoName"
    func removeOwnedBook (bookName: String, bookAuthor: String) {
        
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail())/\(OWNEDBOOK_SUB_COLLECTION)", documentName: "\(bookName)-\(bookAuthor)")
        
    }
    
    
    //Remove book from OwnedBook from Firestore: Users/currentUser/WishList/Document "BookName-AuthoName"
    func removeWishListBook (bookName: String, bookAuthor: String) {
        
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail())/\(WISHLIST_SUB_COLLECTION)", documentName: "\(bookName)-\(bookAuthor)")
        
    }
    
    
    //Remove Friend from Friends from Firestore: Users/currentUser/Friends/Document "friend's email"
    func removeFriend (friendsEmail: String ){
        
        //Removing as friend from current user's  friends collection
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail())/\(FRIENDS_SUB_COLLECTION)", documentName: "\(friendsEmail)")
        
        increment_OR_DecrementNumberOfFriends(userEmail: authInstance.getCurrentUserEmail(), by: -1)
        
        //Removing as friend from other user's (Friend of current user) friends collection
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(friendsEmail)/\(FRIENDS_SUB_COLLECTION)", documentName: "\(authInstance.getCurrentUserEmail())")
        
        increment_OR_DecrementNumberOfFriends(userEmail: friendsEmail, by: -1)
        
    }
    
    
    func removeBookFromHoldings (bookName: String, bookAuthor: String, bookHolder : String){
        
        //Removing as book data from holdings of the bookHolder user
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(bookHolder)/\(HOLDINGS_SUB_COLLECTION)", documentName: "\(bookName)-\(bookAuthor)")
        
    }
    
    //Method to remove friend reqest notification
    func removeFriendRequestNotification (sendersEmail : String, reciverEmail : String) {
        
        let path =  "\(USERS_MAIN_COLLECTIN)/\(reciverEmail)/\(NOTIFICATION_SUB_COLLECTION)"
        
        //friend request document format : sender's email-Friend Request
        let docName = "\(sendersEmail)-\(FRIEND_REQUEST_NOTIFICATION)"
        deleteDocument(documentPath: path, documentName: docName)
        
        
    }
    
    
    //Method to remove book swap reqest notification
    func removeBookSwapRequestNotification (sendersEmail : String, reciverEmail : String, bookName : String, bookAuthor: String) {
        
        let path =  "\(USERS_MAIN_COLLECTIN)/\(reciverEmail)/\(NOTIFICATION_SUB_COLLECTION)"
        
        //book swap request document format : sender's email-bookName-bookAuthor
        let docName = "\(sendersEmail)-\(bookName)-\(bookAuthor)"
        deleteDocument(documentPath: path, documentName: docName)
        
    }
    
    
    //MARK: Remove A field form a Document
    private func removeField (path : String, documenName : String, fieldName : String) {
        
        db.collection(path).document(documenName).updateData([
            fieldName : FieldValue.delete(),
        ]) { err in
            _ = self.checkError(error: err , whileDoing:"deleting \(self.UPDATED_TO_COREDATA_FIELD)")
        }
    }
    
    func removeCoreDataFieldFromFriends(currentUserEmail : String, friendsEmail: String) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(currentUserEmail)/\(FRIENDS_SUB_COLLECTION)/"
        
        removeField(path: path, documenName: friendsEmail, fieldName: UPDATED_TO_COREDATA_FIELD)
    }
    
    
    
    
    
    //Checks if user is holding the max number of book allowed to hold
    func canUserHoldMoreBook () -> Bool {
        
        if (numberOfHoldingBooks ?? 0 < MAX_HOLDING_BOOKS) {
            return true
        } else {
            return false
        }
    }
    
    //Once user logout, this method will be called to reset rating and swap.
    //Why? : If new user is logged in and rating and swaps are not nil, it will show previously logged in user's details
    func resetRatingAndSwaps() {
        rating = nil
        numberOfSwaps = nil
        numberOfHoldingBooks = nil
    }
    
    //MARK: Error
    private func checkError (error: Error?, whileDoing: String) -> Bool{
        
        //ternary operator
        //(error == err) ? print("Number of Swaps for Current User is incremented.") : print("Error while \(whileDoing): \(String(describing: error))")
        
        if error?.localizedDescription == nil{
            print("Successful \(whileDoing)! Class: FirebaseDatabase.swift")
            return true
        } else {
            print("Error while \(whileDoing) .: \(String(describing: error)) Class: FirebaseDatabase.swift")
            return false
        }
            
    }
    
    
}


