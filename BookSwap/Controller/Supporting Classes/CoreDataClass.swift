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
        // Create Batch Delete Request
        let friendsDeleteRequest = NSBatchDeleteRequest(fetchRequest: friendsFetchRequest)
        let booksDeleteRequest = NSBatchDeleteRequest(fetchRequest: booksFetchRequest)
        let wishListDeleteRequest = NSBatchDeleteRequest(fetchRequest: wishListFetchRequest)
        let holdingBookDeleteRequest = NSBatchDeleteRequest(fetchRequest: holdingBookFetchRequest)
        do {
            try self.context.execute(friendsDeleteRequest)
            try self.context.execute(booksDeleteRequest)
            try self.context.execute(wishListDeleteRequest)
            try self.context.execute(holdingBookDeleteRequest)
            
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
        addDataIntoEntities()
    }
    
    
    //Adding data of Friends, OwnedBook and WishList into Core Data Entity
    private func addDataIntoEntities (){
        
        //Getting list of Friends from Firestore Database
        databaseInstance.getListOfFriends(usersEmail: authInstance.getCurrentUserEmail()) { (friendDict) in
            print("From CoreDataClass addDataIntoEntities: \(friendDict as AnyObject)")
            self.addFriendList(friendList: friendDict)
        }
        
        //Getting list of OwnedBook from Firestore Database
        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail(), trueForOwnedBookFalseForWishList: true) { (dict) in
            print("OwnedBook From CoreDataClass addDataIntoEntities: \(dict as AnyObject)")
            self.addBooksIntoOwnedBook(dictionary: dict)
        }
        
        //Getting list of WishList books from Firestore Database
        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail(), trueForOwnedBookFalseForWishList: false) { (dict) in
            print("Wish ListFrom CoreDataClass addDataIntoEntities: \(dict as AnyObject)")
            self.addBooksIntoWishList(dictionary: dict)
        }
        
        //Getting list of HoldingBook from FireStore Database
        databaseInstance.getHoldingBooks(usersEmail: authInstance.getCurrentUserEmail()) { (holdingBookDict) in
            //call function to add holding book
            self.addHoldinBook(holdingBook: holdingBookDict)
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
            //newOwnedBook.holder = (data[databaseInstance.BOOK_HOLDER_FIELD] as! String)

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
            
            holdingBooks.append(book)
        }
        
        saveContext()
    }

    //Adding list of friends and their details inside Core Data Model
    private func addFriendList (friendList : Dictionary<Int , Dictionary<String  , Any>>) {

        var friends = [Friends]()

        for (_, data) in friendList {

            //Getting the latest Context, as saveContext is called before loop ends

            let newFriend = Friends(context: getContext())
            newFriend.friendsEmail = (data[databaseInstance.FRIENDSEMAIL_FIELD] as! String)
            newFriend.numOfSwaps = (data[databaseInstance.NUMBER_OF_SWAPS_FIELD] as! Int32)
            newFriend.userName = (data[databaseInstance.USERNAME_FIELD] as! String)
            
            friends.append(newFriend)
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
    private func addHistoryData (dictionary : Dictionary<String, Dictionary<String, Any>>) {

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
    
    
    //MARK: Change data of sigle file
    func changeBookStatusAndHolder (bookName : String, bookAuthor: String, bookHolder : String, status : Bool ) {
        
        let book = getOwnedBook(bookName: bookName, bookAuthor: bookAuthor)
        
        book[0].status = status
        //book[0].holder = bookHolder
        
        saveContext()
    }
    
    
    func removeFriend (friendsEmail : String) {
        
        var friend = getFriendData(email: friendsEmail)
        
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
