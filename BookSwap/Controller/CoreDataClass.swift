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
    
    
    //Singleton
    static let sharedCoreData = CoreDataClass()
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}
    
//    func getContext() -> NSManagedObjectContext {
//        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//    }
    
    // save function
    func saveItems()
    {
        do {
            try context.save()
            print("saved")
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    
    
    func updateCoreData() {
        getBooksFromFirebase()
        getWishListFromFirebase()
        getFriendsFromFirebase()
    }
    
    
    //read data from firebase...
    func getBooksFromFirebase(){

        var bookList = [OwnedBook(context: self.context)]
        //read data into tmp variable
        
        self.saveItems()
    }

    func getWishListFromFirebase() {
        var wishList = [WishList(context: self.context)]

        self.saveItems()
    }

    func getFriendsFromFirebase() {
        var friendList = [Friends(context: self.context)]

    
        self.saveItems()
    }

    
    
    //reser CoreData
    
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
        } catch {
            print("Error deteting entitry \(error)")
        }
    }
    
    
    
    
    
    
    
//
//    //MARK: Update all entities
//    func updateCoreData () {
//
//        let bookList = OwnedBook(context: self.context)
//        let wishList = WishList(context: self.context)
//        let friendList = Friends(context: self.context)
//
//        databaseInstance.getListOfFriends(usersEmail: authInstance.getCurrentUserEmail()!) { (friendList) in
//            self.addFriendList(friends: friendList)
//        }
//        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail()!, trueForOwnedBookFalseForWishList: true) { (dict) in
//            self.addBooksIntoOwnedBook(dictionary: dict)
//        }
//
//        databaseInstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.getCurrentUserEmail()!, trueForOwnedBookFalseForWishList: false) { (dict) in
//            self.addBooksIntoWishList(dictionary: dict)
//        }
//
//    }
//
//
//    //MARK: Add methods to add data to entities
//    //Adding books into OwnedBook when user signUp
//    func addBooksIntoOwnedBook (dictionary : Dictionary<Int, Dictionary<String, Any>>) {
//
//        //let bookContext = OwnedBook(context: getContext())
//        deleteAllData(entity: OWNED_BOOK_ENTITY)
//
//        for (_, data) in dictionary {
//
//             //Getting the latest Context, as saveContext is called before loop ends
//
////            context.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
////            context.author = (data[databaseInstance.AUTHOR_FIELD] as! String)
////            context.status = data[databaseInstance.BOOK_STATUS_FIELD] as! Bool
////
//            saveContext()
//        }
//    }
//
//    //Adding books into WishList when user signUp
//    func addBooksIntoWishList(dictionary : Dictionary<Int, Dictionary<String, Any>>) {
//
//        deleteAllData(entity: WISH_LIST_ENTITY)
//
//        for (_, data) in dictionary {
//
//            //Getting the latest Context, as saveContext is called before loop ends
//
////            context.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
////            context.author = (data[databaseInstance.AUTHOR_FIELD] as! String)
////
//            saveContext()
//        }
//    }
//
//
//    //Adding list of friends and their details inside Core Data Model
//    func addFriendList (friends : Friends) {
//
//        deleteAllData(entity: FRIENDS_ENTITY)
//
//        for (userEmail, data) in friends {
//
//            //Getting the latest Context, as saveContext is called before loop ends
//
////            context.friendsEmail = userEmail
////            context.numOfSwaps = (data[databaseInstance.NUMBER_OF_SWAPS_FIELD] as! Int32)
////            context.userName = (data[databaseInstance.USERNAME_FIELD] as! String)
////
//            saveContext()
//        }
//    }
//
//
//    //Adding history data to core data model
//    func addHistoryData (dictionary : Dictionary<String, Dictionary<String, Any>>) {
//
//    }
//
//
//    //Use of this function is when user sign out, this method will clear all data from all entities
//    func clearAllEntity ()  {
//
//        let currentUser = FirebaseAuth.sharedFirebaseAuth.getCurrentUserEmail()
//        //Checking if user is still loged in
//        if currentUser == nil {
//
//            deleteAllData(entity: FRIENDS_ENTITY)
//            deleteAllData(entity: OWNED_BOOK_ENTITY)
//            deleteAllData(entity: WISH_LIST_ENTITY)
//
//        } else {
//            print("Error while clearing all entities. \(currentUser!) is still loged in.")
//        }
//    }
//    func saveContext() {
//        AppDelegate().saveContext()
////        do {
////            try getContext().save()
////            print("Context is saved.")
////        } catch {
////            print("Error saving context \(error)")
////        }
//
//    }
//
//
//    //Deletes all data stored inside the entity
//    func deleteAllData(entity: String)
//    {
//
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
//        fetchRequest.returnsObjectsAsFaults = false
//
//        do {
//            let results = try managedContext.fetch(fetchRequest)
//
//            for managedObject in results {
//                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
//                managedContext.delete(managedObjectData)
//            }
//            print("All data deleted in entity: \(entity)")
//        } catch let error as NSError {
//            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
//        }
//    }
}
