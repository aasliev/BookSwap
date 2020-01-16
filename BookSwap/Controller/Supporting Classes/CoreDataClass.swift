//
//  CoreData.swift
//  BookSwap
//
//  Created by RV on 11/20/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataClass {
    
    let FRIENDS_ENTITY =  "Friends"
    let OWNED_BOOK_ENTITY = "OwnedBook"
    let WISH_LIST_ENTITY = "WishList"
    let HOLDING_BOOKS = "HoldBook"
    let HISTORY_ENTITY = "History"
    
    //Adding name of the attributes in each entity.
    //NOTE: Need to set 'bookName' and 'bookAuthor' to all entity where book is stored. Doing this will help to -
    //- reduce different variable for each entity. One variable can be used for book attribute for all entity where required
    let HISTORY_ATTRIBUTE_BOOK_NAME = "bookName"
    let HISTORY_ATTRIBUTE_BOOK_AUTHOR = "authorName"
    let HISTORY_ATTRIBUTE_SENDER =  "sendersEmail"
    let HISTORY_ATTRIBUTE_RECIVER = "reciversEmail"
    let HISTORY_ATTRIBUTE_IN_PROCESS_STATUS = "inProcessStatus"
    
    var ownedBook = [OwnedBook]()
    var friendList = [Friends]()
    
    //Singleton
    static let sharedCoreData = CoreDataClass()
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}
    
    func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func resetOneEntity(entityName : String) {

        let entityFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let entityDeleteRequest = NSBatchDeleteRequest(fetchRequest: entityFetchRequest)
        do {
            
            try self.context.execute(entityDeleteRequest)
            
            print("Successfully Emptied Core Data.")
        } catch {
            print("Error deteting entitry \(error)")
        }
    }

    
    //Use of this function is when user sign out, this method will clear all data from all entities
    func resetAllEntities() {
        let friendsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FRIENDS_ENTITY)
        let booksFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: OWNED_BOOK_ENTITY)
        let wishListFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: WISH_LIST_ENTITY)
        let holdingBookFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: HOLDING_BOOKS)
        let historyFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: HISTORY_ENTITY)
        // Create Batch Delete Request
        let friendsDeleteRequest = NSBatchDeleteRequest(fetchRequest: friendsFetchRequest)
        let booksDeleteRequest = NSBatchDeleteRequest(fetchRequest: booksFetchRequest)
        let wishListDeleteRequest = NSBatchDeleteRequest(fetchRequest: wishListFetchRequest)
        let holdingBookDeleteRequest = NSBatchDeleteRequest(fetchRequest: holdingBookFetchRequest)
        let historyDeleteRequest = NSBatchDeleteRequest(fetchRequest: historyFetchRequest)
        
        do {
            try self.context.execute(friendsDeleteRequest)
            try self.context.execute(booksDeleteRequest)
            try self.context.execute(wishListDeleteRequest)
            try self.context.execute(holdingBookDeleteRequest)
            try self.getContext().execute(historyDeleteRequest)
            
            print("Successfully Emptied Core Data.")
        } catch {
            print("Error deteting entitry \(error)")
        }
    }
    

    //MARK: Update all entities
    func updateCoreData () {
        
        //First, in case there is data stored inside Core Data resetAllEntities() will clear it.
        resetAllEntities()

        //Second, adding data into CoreData. Which is recived from Firestore.
        addDataIntoAllEntities()
    }
    
    
    //Adding data of Friends, OwnedBook and WishList into Core Data Entity
    private func addDataIntoAllEntities (){
        
        addDataIntoFriendEntity()
        
        addDataIntoOwnedBookEntity()
        
        addDataIntoWishListEntity()
        
        addDataIntoHoldingsEntity()
        
        addDataIntoHistoryEntity()
        
    }
    
    
    //Mark: Methods to Update single entity
    func addDataIntoFriendEntity () {
        
        //Getting list of Friends from Firestore Database
        databaseInstance.getListOfFriends(usersEmail: authInstance.getCurrentUserEmail()) { (friendDict) in
            print("From CoreDataClass addDataIntoEntities: \(friendDict as AnyObject)")
            self.addFriendList(friendList: friendDict)
        }
    }
    
    func addDataIntoOwnedBookEntity () {
        
        //Getting list of OwnedBook from Firestore Database
        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail(), trueForOwnedBookFalseForWishList: true) { (dict) in
            print("OwnedBook From CoreDataClass addDataIntoEntities: \(dict as AnyObject)")
            self.addBooksIntoOwnedBook(dictionary: dict)
        }
       
    }
    
    func addDataIntoWishListEntity () {
        
        //Getting list of WishList books from Firestore Database
        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail(), trueForOwnedBookFalseForWishList: false) { (dict) in
            print("Wish ListFrom CoreDataClass addDataIntoEntities: \(dict as AnyObject)")
            self.addBooksIntoWishList(dictionary: dict)
        }
        
    }
    
    func addDataIntoHoldingsEntity () {
        
        //Getting list of HoldingBook from FireStore Database
        databaseInstance.getHoldingBooks(usersEmail: authInstance.getCurrentUserEmail()) { (holdingBookDict) in
            //call function to add holding book
            self.addHoldinBook(holdingBook: holdingBookDict)
        }
    
    }
    
    func addDataIntoHistoryEntity () {
        
        databaseInstance.getHistoryData(usersEmail: authInstance.getCurrentUserEmail()) { (historyDict) in
            
            self.addHistoryData(dictionary: historyDict)
        }
        
    }
    

    //MARK: Add methods to add data to entities
    //Adding books into OwnedBook when user signUp
    private func addBooksIntoOwnedBook (dictionary : Dictionary<Int, Dictionary<String, Any>>) {

        
        for (_, data) in dictionary {

            let newOwnedBook = OwnedBook(context: getContext())
            newOwnedBook.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
            newOwnedBook.author = (data[databaseInstance.AUTHOR_FIELD] as! String)
            newOwnedBook.status = data[databaseInstance.BOOK_STATUS_FIELD] as! Bool
            newOwnedBook.holder = (data[databaseInstance.BOOK_HOLDER_FIELD] as! String)

            ownedBook.append(newOwnedBook)
            
        }
        
         //Once all necessary changes has been made, saving the context into persistent container.
        saveContext()
    }
    

    //Adding books into WishList when user signUp
    private func addBooksIntoWishList(dictionary : Dictionary<Int, Dictionary<String, Any>>) {

        //Empty Array of WishList object
        var wishList = [WishList]()
     
        for (_, data) in dictionary {

            //Getting the latest Context, as saveContext is called before loop ends
            let newWishList = WishList(context: getContext())
            newWishList.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
            newWishList.author = (data[databaseInstance.AUTHOR_FIELD] as! String)

            //Adding new book into wishList array
            wishList.append(newWishList)
        }
        
         //Once all necessary changes has been made, saving the context into persistent container.
        saveContext()
    }

    
    //add holdingBook to Core Data
    private func addHoldinBook(holdingBook : Dictionary<Int, Dictionary<String, Any>>){
        
        var holdingBooks = [HoldBook]()
        for(_, data) in holdingBook {
            let book = HoldBook(context: getContext())
            
            book.author = (data[databaseInstance.AUTHOR_FIELD] as! String)
            book.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
            book.bookOwner = (data[databaseInstance.BOOK_OWNER_FIELD] as! String)
            book.returnRequested = (data[databaseInstance.RETURN_REQUESTED_FIELD] as! Bool)
            
            holdingBooks.append(book)
        }
        
        saveContext()
    }

    //Adding list of friends and their details inside Core Data Model
    func addFriendList (friendList : Dictionary<Int , Dictionary<String  , Any>>) {

        var friends = [Friends]()

        for (_, data) in friendList {

            let friendsEmail = data[databaseInstance.FRIENDSEMAIL_FIELD] as! String
            if (!checkIfFriend(friendEmail: friendsEmail)) {
                //Getting the latest Context, as saveContext is called before loop ends
                let newFriend = Friends(context: getContext())
                newFriend.friendsEmail = friendsEmail
                newFriend.numOfSwaps = (data[databaseInstance.NUMBER_OF_SWAPS_FIELD] as! Int32)
                newFriend.userName = (data[databaseInstance.USERNAME_FIELD] as! String)
                
                friends.append(newFriend)
            } else {
                print ("Friend already exist in core data")
            }
            
            databaseInstance.removeCoreDataFieldFromFriends(currentUserEmail: authInstance.getCurrentUserEmail(), friendsEmail: friendsEmail)
        }
    
         //Once all necessary changes has been made, saving the context into persistent container.
        saveContext()
    }
    
    
    //Method to add a single friend. 
    func addAFriendIntoCoreData (friendsEmail : String, friendsUserName : String, numberOfSwaps : String) {
        
        var friends = [Friends]()
        //Getting the latest Context, as saveContext is called before loop ends
        
        let newFriend = Friends(context: getContext())
        newFriend.friendsEmail = (friendsEmail)
        newFriend.numOfSwaps = Int32(numberOfSwaps)!
        newFriend.userName = (friendsUserName)
        
        friends.append(newFriend)
        saveContext()
    }
    


    //Adding history data to core data model
    private func addHistoryData (dictionary : Dictionary<Int, Dictionary<String, Any>>) {
        
        var history = [History]()
        
        for (index, data) in dictionary {
            
            //Getting the latest Context, as saveContext is called before loop ends
            
            let newHistoryData = History(context: getContext())
            let sendersEmail = (data[databaseInstance.SENDERS_EMAIL_FIELD] as! String)
            let reciversEmail = (data[databaseInstance.RECEIVERS_EMAIL_FIELD] as! String)
            let bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
            let bookAuthor = (data[databaseInstance.AUTHOR_FIELD] as! String)
            let inProcessStatus = (data[databaseInstance.SWAP_IN_PROCESS] as! Bool)
            
            newHistoryData.sendersEmail = sendersEmail
            newHistoryData.reciversEmail = reciversEmail
            newHistoryData.bookName = bookName
            newHistoryData.authorName = bookAuthor
            newHistoryData.inProcessStatus = inProcessStatus
            newHistoryData.assignNumber = Int32(index)
            
            history.append(newHistoryData)
        }
        
        
        //Once all necessary changes has been made, saving the context into persistent container.
        saveContext()

    }
    
    
    //MARK: Checking if data exist in Core Data
    //Method will be used to check if a user is friend of logged in user
    func checkIfFriend (friendEmail : String) -> Bool {
        
        print ("This is Friends Email:\(friendEmail)")
        let friendList = getFriendData(email: friendEmail)
        return friendList.count > 0;
    }
    
    //Method will be used to check if a user is book is in CoreData
    func checkIfOwnedBookExist (bookName : String, bookAuthor : String) -> Bool {
        
        let book = getOwnedBook(bookName: bookName, bookAuthor: bookAuthor)
        
        return book.count > 0
    }
    
    func checkIfWishListBookExist (bookName : String, bookAuthor : String) -> Bool {
        
        let book = getWishListBook(bookName: bookName, bookAuthor: bookAuthor)
        
        return book.count > 0
    }
    
    
    //MARK : Get Methods
    private func getFriendData (email : String) -> [Friends] {
        
        let requestForFriends: NSFetchRequest<Friends> = Friends.fetchRequest()
        requestForFriends.predicate = NSPredicate(format: "friendsEmail CONTAINS %@",  email )
        
        var results = [Friends]()
        
        do {
            results = try getContext().fetch(requestForFriends)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results
        
        
    }
    
    
    private func getOwnedBook (bookName : String, bookAuthor : String) -> [OwnedBook] {
        
        //Creating a request, which fetch all the books
        let requestForFriends: NSFetchRequest<OwnedBook> = OwnedBook.fetchRequest()
        
        //Searching for the one book
        requestForFriends.predicate = NSPredicate(format: "(bookName CONTAINS[cd] %@) AND (author CONTAINS[cd] %@)",  bookName, bookAuthor )
        
        var bookData = [OwnedBook]()
        
        do {
            bookData = try getContext().fetch(requestForFriends)
            
            print("Result of results.count: \(bookData.count)")
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return bookData
        
    }
    
    //For Wish List books
    private func getWishListBook (bookName : String, bookAuthor : String) -> [WishList] {
        
        //Creating a request, which fetch all the books
        let requestForFriends: NSFetchRequest<WishList> = WishList.fetchRequest()
        
        //Searching for the one book
        requestForFriends.predicate = NSPredicate(format: "(bookName CONTAINS[cd] %@) AND (author CONTAINS[cd] %@)",  bookName, bookAuthor )
        
        var bookData = [WishList]()
        
        do {
            bookData = try getContext().fetch(requestForFriends)
            
            print("Result of results.count: \(bookData.count)")
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return bookData
        
    }
    
    //Getting History from CoreData
    private func getSingleHistory (sender: String, bookName : String, bookAuthor : String, reciver: String) -> [History] {
        
        //Creating a request, which fetch all the books
        let requestForFriends: NSFetchRequest<History> = History.fetchRequest()
        
        //Creating search queries
        let searchQuery_sender = "\(HISTORY_ATTRIBUTE_SENDER) CONTAINS[cd] %@"
        let searchQuery_bookName = "\(HISTORY_ATTRIBUTE_BOOK_NAME) CONTAINS[cd] %@"
        let searchQuery_bookAuthor = "\(HISTORY_ATTRIBUTE_BOOK_AUTHOR) CONTAINS[cd] %@"
        let searchQuery_reciver = "\(HISTORY_ATTRIBUTE_RECIVER) CONTAINS[cd] %@"
        
        //Searching for the one history
        requestForFriends.predicate = NSPredicate(format: "(\(searchQuery_sender)) AND (\(searchQuery_bookName) AND \(searchQuery_bookAuthor)) AND (\(searchQuery_reciver))",  sender, bookName, bookAuthor, reciver )
        
        var bookData = [History]()
        
        do {
            bookData = try getContext().fetch(requestForFriends)
            
            print("Result of results.count: \(bookData.count)")
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return bookData
        
    }
    
    
    //MARK: Change data of a single file
    
    //To update data of Bookshelf (OwnedBook)
    func changeBookStatusAndHolder (bookName : String, bookAuthor: String, bookHolder : String, status : Bool ) {
        
        let book = getOwnedBook(bookName: bookName, bookAuthor: bookAuthor)
        
        //Note: Expacting only file. That's why index is '0'
        book[0].status = status
        book[0].holder = bookHolder
        
        saveContext()
    }
    
    
    //to Update HIstory
    func changeSwapInProcessStatusForHistory(sender: String, bookName: String, bookAuthor : String, reciver: String, status: Bool) {
        
        let history = getSingleHistory(sender: sender, bookName: bookName, bookAuthor: bookAuthor, reciver: reciver)
        
        print(history)
        //Note: Expacting only file. That's why index is '0'
        history[0].inProcessStatus = status
    }
    
    //MARK: Update CoreData
    //These methods are called to update the coredata, for changes made to Firestore while user were offline

    func updateOwnedBook(dictionary: Dictionary<Int, Dictionary<String, Any>>){
        
        for (_,data) in dictionary {
            let bookName = data[databaseInstance.BOOKNAME_FIELD] as! String
            let bookAuthor = data[databaseInstance.AUTHOR_FIELD] as! String
            let bookHolder = data[databaseInstance.BOOK_HOLDER_FIELD] as! String
            let bookStatus = data[databaseInstance.BOOK_STATUS_FIELD] as! Bool
            
            //var bookData = getOwnedBook(bookName: bookName, bookAuthor: bookAuthor)
            
            changeBookStatusAndHolder(bookName: bookName, bookAuthor: bookAuthor, bookHolder: bookHolder, status: bookStatus)
            
            databaseInstance.changeUpdatedCoreDataStatusForOwnedBook(userEmail: authInstance.getCurrentUserEmail(), bookName: bookName, bookAuthor: bookAuthor, status: true)
        }
    }
    
    
    func updateHistory(dictionary: Dictionary<Int, Dictionary<String, Any>>){
        
        for (_,data) in dictionary {
            let bookName = data[databaseInstance.BOOKNAME_FIELD] as! String
            let bookAuthor = data[databaseInstance.AUTHOR_FIELD] as! String
            let sender = data[databaseInstance.SENDERS_EMAIL_FIELD] as! String
            //As reciver name is added later, some document might doesn't have reciver field.
            //To make sure app doesn't crash checking if it's nil. If nil, reciver = '-1'
            let reciver = (data[databaseInstance.RECEIVERS_EMAIL_FIELD] ?? "-1") as! String
            let inProcessStatus = (data[databaseInstance.SWAP_IN_PROCESS]) as! Bool
            
            reciver == "-1" ? print("Reciver is missing for book: \(bookName)") :
            
            changeSwapInProcessStatusForHistory(sender: sender, bookName: bookName, bookAuthor: bookAuthor, reciver: reciver, status: inProcessStatus)
            
        databaseInstance.changeUpdatedCoreDataStatusForHistory(usersEmail: authInstance.getCurrentUserEmail(), sender: sender, bookName: bookName, bookAuthor: bookAuthor, reciver: reciver, status: true)
        }
    }
    
    
    
    func removeFriend (friendsEmail : String) {
        
        let friend = getFriendData(email: friendsEmail)
        
        for object in friend {
            getContext().delete(object)
        }
        
        saveContext()
        
    }


    //The changes made in context, this method saves it into Persistent Container(Main SQLite database)
    func saveContext() {
        
        do {
            try getContext().save()
            print("Context is saved.")
        } catch {
            print("Error saving context \(error)")
        }
    }

    
    
}
