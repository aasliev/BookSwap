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
    let SENDERS_USER_NAME_FIELD = "Sende's UserName"
    let RECEIVERS_EMAIL_FIELD = "Receiver"
    let NOTIFICATION_TYPE = "Type"
    
    //Notification Types
    let BOOKSWAP_REQUEST_NOTIFICATION = "Book Swap"
    let FRIEND_REQUEST_NOTIFICATION = "Friend Request"
    
    let TIMESTAMP = "Timestamp"
    
    //MARK: Collection Paths
    let USER_COLLECTION_PATH : String
    
    //MARK: Collection Reference
    let USER_COLLECTION_REF : CollectionReference
    
    var path : String = ""
    var message : String = ""
    var ref : DocumentReference
    
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
            NUMBEROFFRIENDS_FIELD: 0])
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
            NUMBER_OF_SWAPS_FIELD: 0
            
        ]) { err in
            
            if(self.checkError(error: err, whileDoing: "adding new friend")){
                self.increment_OR_DecrementNumberOfFriends(userEmail: currentUserEmail, by: 1)
                if(recursion) {
                    self.addNewFriend(currentUserEmail: friendsEmail, friendsEmail: currentUserEmail, friendsUserName: self.authInstance.getUserName(), recursion: false)
                    
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
    func addHoldingBook (bookOwnerEmail: String, bookRequester : String, bookName: String, bookAuthor: String ) {
        
        path = "\(USERS_MAIN_COLLECTIN)/\(bookRequester)/\(HOLDINGS_SUB_COLLECTION)"
        ref = db.collection(path).document("\(bookName)-\(bookAuthor)")
        
        ref.setData([
            
            BOOKNAME_FIELD: bookName,
            AUTHOR_FIELD: bookAuthor,
            BOOK_OWNER_FIELD : bookOwnerEmail
            
            
        ]) { err in
            
            _ = self.checkError(error: err, whileDoing: "adding book to Holdings")
        }
        
        //Changing book holder's email, so user can keep track of who has the book, and changing book status
        changeBookHoldersEmail(bookOwnersEmail: bookOwnerEmail, bookReciversEmail: authInstance.getCurrentUserEmail()!, bookName: bookName, bookAuthor: bookAuthor, bookStatus: false)

    }
    
    
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
    }
    
    
    //This method will be called when user confirms that he recived a book back
    func successfullyReturnedHoldingBook (bookName : String, bookAuthor : String) {
        
        //First need to get the name  of the holder of the book, which will be done by this function
        getBookHoldersEmail(bookName: bookName, bookAuthor: bookAuthor) { (bookHolder) in
            
            //Completion wil return '-1' if some error occured
            if bookHolder != "-1" {
                
                //Second, changing the holder field inside Firestore: Users/currentUser's Email/OwnedBook/bookName-bookAuthor
                self.changeBookHoldersEmail(bookOwnersEmail: self.authInstance.getCurrentUserEmail()!, bookReciversEmail: self.authInstance.getCurrentUserEmail()!, bookName: bookName, bookAuthor: bookAuthor, bookStatus: true)
                
                //Removes the book book from holdingBooks
                self.removeBookFromHoldings(bookName: bookName, bookAuthor: bookAuthor, bookHolder: bookHolder)
            }
        }
    }
    
    //MARK: Increment Methods
    //Method increments field "numberOfSwaps" by 1 inside Firestore: Users/currentUser/Friends/friendsEmail document
    private func incrementNumberOfSwapsInFriendsSubCollection(currentUserEmail: String,friendsEmail: String, recursion: Bool) {
        
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
                dictionary.removeValue(forKey: self.authInstance.getCurrentUserEmail()!)
                
                completion(dictionary)
                
            }
        }
    }
    
    //Common method to get all documents from sub collections, will be called from other get methods
    private func getDocuments (docPath : String, docMessage : String, completion: @escaping (Dictionary<Int , Dictionary<String  , Any>>)->())  {
        
        var dictionary : Dictionary<Int, Dictionary<String  , Any>> = [:]
        
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
    func getHistoryData (usersEmail: String, friendsEmail: String, completion: @escaping (Dictionary<Int  , Dictionary<String  , Any>>)->()){
        
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
    
    
    //MARK: Get Field Data of a Document
    //Gets the field of current user from Firestore: Users/currentUser/Document "Field"
    private func getFieldData(usersEmail: String, fieldName: String, completion: @escaping (Any)->()) {
        
        
        db.collection(USERS_MAIN_COLLECTIN).document(usersEmail).getDocument { (document, error) in
            
            if let document = document, document.exists {
                
                let fieldData = document.get(fieldName)
                
                completion(fieldData as Any)
                
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
                completion("Updating...")
            }
            //completion((userName ?? "Updating" ) as! String)
            
        }
    }
    
    //Gets rating of current user from Firestore: Users/currentUser/Document "Rating"
    func getRating(usersEmail: String, completion: @escaping (Int)->()) {
        
        getFieldData(usersEmail: usersEmail.lowercased(), fieldName: RATING_FIELD){ rating in
            
            if ((rating as? Int != nil) && (rating as! Int != -1)){
                completion(rating as! Int)
            } else {
                completion(-1)
            }
            
        }
    }
    
    //Gets rating of current user from Firestore: Users/currentUser/Document "NumberOfSwaps"
    func getNumberOfSwaps(usersEmail: String, completion: @escaping (Int)->()) {
        
        getFieldData(usersEmail: usersEmail, fieldName: NUMBER_OF_SWAPS_FIELD) { swaps in
            
            if ((swaps as? Int != nil) && (swaps as! Int != -1)){
                completion(swaps as! Int)
            } else {
                completion(-1)
            }
        }
    }
    
    
    //Returns Book owner's email which is stored inside Firestore: Users/Book holder's Email/Holdings/bookName-bookAuthor. Called by method successfullyReturnedHoldingBook
    private func getBookOwnerFromHoldings(bookName: String, bookAuthor: String, completion: @escaping (String)->()) {
        
        db.collection("\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail()!)/\(HOLDINGS_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").getDocument { (document, error) in
            
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
    private func getBookHoldersEmail(bookName: String, bookAuthor: String, completion: @escaping (String)->()) {
        
        db.collection("\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail()!)/\(OWNEDBOOK_SUB_COLLECTION)").document("\(bookName)-\(bookAuthor)").getDocument { (document, error) in
            
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
        
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail()!)/\(OWNEDBOOK_SUB_COLLECTION)", documentName: "\(bookName)-\(bookAuthor)")
        
    }
    
    
    //Remove book from OwnedBook from Firestore: Users/currentUser/WishList/Document "BookName-AuthoName"
    func removeWishListBook (bookName: String, bookAuthor: String) {
        
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail()!)/\(WISHLIST_SUB_COLLECTION)", documentName: "\(bookName)-\(bookAuthor)")
        
    }
    
    
    //Remove Friend from Friends from Firestore: Users/currentUser/Friends/Document "friend's email"
    func removeFriend (friendsEmail: String ){
        
        //Removing as friend from current user's  friends collection
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(authInstance.getCurrentUserEmail()!)/\(FRIENDS_SUB_COLLECTION)", documentName: "\(friendsEmail)")
        
        increment_OR_DecrementNumberOfFriends(userEmail: authInstance.getCurrentUserEmail()!, by: -1)
        
        //Removing as friend from other user's (Friend of current user) friends collection
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(friendsEmail)/\(FRIENDS_SUB_COLLECTION)", documentName: "\(authInstance.getCurrentUserEmail()!)")
        
        increment_OR_DecrementNumberOfFriends(userEmail: friendsEmail, by: -1)
        
    }
    
    
    func removeBookFromHoldings (bookName: String, bookAuthor: String, bookHolder : String){
        
        //Removing as book data from holdings of the bookHolder user
        deleteDocument(documentPath: "\(USERS_MAIN_COLLECTIN)/\(bookHolder)/\(HOLDINGS_SUB_COLLECTION)", documentName: "\(bookName)-\(bookAuthor)")
        
    }
    
    
    //Method to remove friend reqest notification
    func removeFriendRequestNotification (sendersEmail : String, reciverEmail : String, document : String) {
        
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


