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
    
    var ownedBook = [OwnedBook]()
    
    
    //Singleton
    static let sharedCoreData = CoreDataClass()
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}
    
    func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    
    //Use of this function is when user sign out, this method will clear all data from all entities
    func resetAllEntities() {
        let friendsFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: FRIENDS_ENTITY)
        let booksFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: OWNED_BOOK_ENTITY)
        let wishListFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: WISH_LIST_ENTITY)
        // Create Batch Delete Request
        let friendsDeleteRequest = NSBatchDeleteRequest(fetchRequest: friendsFetchRequest)
        let booksDeleteRequest = NSBatchDeleteRequest(fetchRequest: booksFetchRequest)
        let wishListDeleteRequest = NSBatchDeleteRequest(fetchRequest: wishListFetchRequest)
        do {
            try self.context.execute(friendsDeleteRequest)
            try self.context.execute(booksDeleteRequest)
            try self.context.execute(wishListDeleteRequest)
            
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
        databaseInstance.getListOfFriends(usersEmail: authInstance.getCurrentUserEmail()!) { (friendDict) in
            self.addFriendList(friendList: friendDict)
        }
        
        //Getting list of OwnedBook from Firestore Database
        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail()!, trueForOwnedBookFalseForWishList: true) { (dict) in
            self.addBooksIntoOwnedBook(dictionary: dict)
        }
        
        //Getting list of WishList books from Firestore Database
        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail()!, trueForOwnedBookFalseForWishList: false) { (dict) in
            self.addBooksIntoWishList(dictionary: dict)
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


    //Adding list of friends and their details inside Core Data Model
    private func addFriendList (friendList : Dictionary<String , Dictionary<String  , Any>>) {

        var friends = [Friends]()

        for (userEmail, data) in friendList {

            //Getting the latest Context, as saveContext is called before loop ends

            let newFriend = Friends(context: getContext())
            newFriend.friendsEmail = userEmail
            newFriend.numOfSwaps = (data[databaseInstance.NUMBER_OF_SWAPS_FIELD] as! Int32)
            newFriend.userName = (data[databaseInstance.USERNAME_FIELD] as! String)
            
            friends.append(newFriend)
        }
        
         //Once all necessary changes has been made, saving the context into persistent container.
        saveContext()
    }


    //Adding history data to core data model
    private func addHistoryData (dictionary : Dictionary<String, Dictionary<String, Any>>) {

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
