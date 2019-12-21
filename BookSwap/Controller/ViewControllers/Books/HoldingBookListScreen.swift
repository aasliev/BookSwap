//
//  HoldingBookListScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class HoldingBookListScreen: UITableViewController {
    
    //arrays
    var currentUserItems = [HoldBook]()
    var otherUserItems = [OtherHoldBook]()

    var currentUser : String?
    
    //fetch request
    var requestForHoldBooks : NSFetchRequest<HoldBook> = HoldBook.fetchRequest()
    var requestForOtherHoldBooks: NSFetchRequest<OtherHoldBook> = OtherHoldBook.fetchRequest()
    
    //instances
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    
    
    override func viewDidLoad() {
        currentUser = authInstance.getUsersScreen()
        print("currentUser: \(currentUser)")
        super.viewDidLoad()
        tableView.rowHeight = 120
        loadItems()
    }
    
    //MARK: Tableview methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code...
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return !authInstance.isItOtherUsersPage(userEmail: currentUser!) ?  currentUserItems.count : otherUserItems.count
        //return currentUserItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "holdListCell", for: indexPath) as! HoldBookTableViewCell
        //initialize cell..
        
        if !authInstance.isItOtherUsersPage(userEmail: currentUser!){
            
            cell.authorOfTheBook.text = currentUserItems[indexPath.row].author
            cell.nameOfTheBook.text = currentUserItems[indexPath.row].bookName
            databaseInstance.getUserName(usersEmail: currentUserItems[indexPath.row].bookOwner!) { (userName) in
                cell.bookOwner.text = userName
            }
            
            cell.returnButton.isHidden = currentUserItems[indexPath.row].returnRequested
            
        } else {
            cell.authorOfTheBook.text = otherUserItems[indexPath.row].author
            cell.nameOfTheBook.text = otherUserItems[indexPath.row].bookName
            cell.bookOwner.text = otherUserItems[indexPath.row].bookOwner
            cell.returnButton.isHidden = true
        }
        return cell
    }
    
    
    //MARK: Model Manipulation Methods
    
    func loadItems() {
        do {
            if !authInstance.isItOtherUsersPage(userEmail: currentUser!){
                currentUserItems = try coreDataClassInstance.getContext().fetch(requestForHoldBooks)
            } else {
                if otherUserItems.count == 0 {
                    print("printing current user: \(currentUser as! String)")
                    databaseInstance.getHoldingBooks(usersEmail: currentUser!) { (otherHoldingList) in
                        self.loadDataForOtherUser(dict: otherHoldingList)
                    }} else {
                        otherUserItems = try coreDataClassInstance.getContext().fetch(requestForOtherHoldBooks)
                    }
                }
                tableView.reloadData()
            } catch {
            print("error fetching data \(error)")
        }
    }
    
    func loadDataForOtherUser(dict: Dictionary<Int, Dictionary<String , Any >>){
        coreDataClassInstance.resetOneEntity(entityName: "OtherHoldBook")
        otherUserItems.removeAll()
        
        for (_, data) in dict {
            let tmpHoldBook = OtherHoldBook(context: coreDataClassInstance.getContext())
            
            tmpHoldBook.bookName = (data[self.databaseInstance.BOOKNAME_FIELD] as! String)
            tmpHoldBook.author = (data[self.databaseInstance.AUTHOR_FIELD] as! String)
            tmpHoldBook.bookOwner = (data[self.databaseInstance.BOOK_OWNER_FIELD] as! String)
            
            otherUserItems.append(tmpHoldBook)
        }
        
        coreDataClassInstance.saveContext()
        tableView.reloadData()
        
    }
}
