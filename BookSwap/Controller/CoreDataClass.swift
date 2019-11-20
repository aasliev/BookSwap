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
    
    //Singleton
    static let sharedCoreData = CoreDataClass()
    
    //let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private init() {}
    
    func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    //Adding books into OwnedBook when user signUp
    func addBooksIntoOwnedBook (dictionary : Dictionary<Int, Dictionary<String, Any>>) {
        
        //let bookContext = OwnedBook(context: getContext())
        deleteAllData(entity: "OwnedBook")
        
        for (_, data) in dictionary {
            
            let bookContext = OwnedBook(context: getContext())
            bookContext.bookName = (data["BookName"] as! String)
            bookContext.author = (data["Author"] as! String)
            bookContext.status = data["BooksStatus"] as! Bool
            
            saveContext()
        }
    }
    
    //Adding books into WishList when user signUp
    func addBooksIntoWishList(dictionary : Dictionary<Int, Dictionary<String, Any>>) {
        
        deleteAllData(entity: "WishList")
        
        for (_, data) in dictionary {
            
            let bookContext = WishList(context: getContext())
            bookContext.bookName = (data["BookName"] as! String)
            bookContext.author = (data["Author"] as! String)
           
            saveContext()
        }
    }
    
    
    func saveContext() {
        
        do {
            try getContext().save()
            print("saved.")
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
