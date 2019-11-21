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
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private init() {}
    
    func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    //Adding books into OwnedBook when user signUp
    func addBooksIntoOwnedBook (dictionary : Dictionary<Int, Dictionary<String, Any>>) {
        
        //let bookContext = OwnedBook(context: getContext())
        deleteAllData(entity: OWNED_BOOK_ENTITY)
        
        for (_, data) in dictionary {
            
             //Getting the latest Context, as saveContext is called before loop ends
            let contextRef = OwnedBook(context: getContext())
            
            contextRef.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
            contextRef.author = (data[databaseInstance.AUTHOR_FIELD] as! String)
            contextRef.status = data[databaseInstance.BOOK_STATUS_FIELD] as! Bool
            
            saveContext()
        }
    }
    
    //Adding books into WishList when user signUp
    func addBooksIntoWishList(dictionary : Dictionary<Int, Dictionary<String, Any>>) {
        
        deleteAllData(entity: WISH_LIST_ENTITY)
        
        for (_, data) in dictionary {
            
            //Getting the latest Context, as saveContext is called before loop ends
            let contextRef = WishList(context: getContext())
            
            contextRef.bookName = (data[databaseInstance.BOOKNAME_FIELD] as! String)
            contextRef.author = (data[databaseInstance.AUTHOR_FIELD] as! String)
           
            saveContext()
        }
    }
    
    
    //Adding list of friends and their details inside Core Data Model
    func addFriendList (dictionary : Dictionary<String, Dictionary<String, Any>>) {
        
        deleteAllData(entity: FRIENDS_ENTITY)
        
        for (userEmail, data) in dictionary {
            
            //Getting the latest Context, as saveContext is called before loop ends
            let contextRef = Friends(context: getContext())
            
            contextRef.friendsEmail = (userEmail as! String)
            contextRef.numOfSwaps = (data[databaseInstance.NUMBER_OF_SWAPS_FIELD] as! Int32)
            contextRef.userName = (data[databaseInstance.USERNAME_FIELD] as! String)
            
            saveContext()
        }
    }
    
    
    //Use of this function is when user sign out, this method will clear all data from all entities
    func clearAllEntity ()  {
        
        let currentUser = FirebaseAuth.sharedFirebaseAuth.getCurrentUserEmail()
        //Checking if user is still loged in
        if currentUser.isEmpty {
            
            deleteAllData(entity: FRIENDS_ENTITY)
            deleteAllData(entity: OWNED_BOOK_ENTITY)
            deleteAllData(entity: WISH_LIST_ENTITY)
            
        } else {
            print("Error while clearing all entities. \(currentUser) is still loged in.")
        }
    }
    func saveContext() {
        
        do {
            try getContext().save()
            print("Context is saved.")
        } catch {
            print("Error saving context \(error)")
        }
        
    }
    
    
    //Deletes all data stored inside the entity
    func deleteAllData(entity: String)
    {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
}
