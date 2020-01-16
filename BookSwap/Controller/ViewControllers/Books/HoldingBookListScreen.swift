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


class HoldingBookListScreen: UITableViewController, HoldBookCellDelegate {

    //arrays
    var currentUserItems = [HoldBook]()
    var otherUserItems = [OtherHoldBook]()

    var currentUser : String?
    var indexRow : Int?
    
    //fetch request
    var requestForHoldBooks : NSFetchRequest<HoldBook> = HoldBook.fetchRequest()
    var requestForOtherHoldBooks: NSFetchRequest<OtherHoldBook> = OtherHoldBook.fetchRequest()
    
    //instances
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    
    
    override func viewDidLoad() {
        currentUser = authInstance.getUsersScreen()
        //print("currentUser: \(currentUser)")
        super.viewDidLoad()
        tableView.rowHeight = 120
        
        //this disables the selection of row.
        //When user clicks on book, no selection will highlight any row
        tableView.allowsSelection = false
        
        loadItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!authInstance.isItOtherUsersPage(userEmail: currentUser!)){
            databaseInstance.getListofHoldingBooksNotAddedInCoreData(userEmail: authInstance.getCurrentUserEmail()) { (dict) in
                print("Result of CoreData Search inside Holding Books: \(dict as AnyObject)")
                //self.coreDataClassInstance.addFriendList(friendList: dict)
                self.loadItems()
            }
        }
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
        
        cell.delegate = self
        
        //Method is used to keep track of indexPath.row for each button
        addButtonTargetAndSetTagValue(tableCell: cell, index: indexPath.row)
        
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
            databaseInstance.getUserName(usersEmail: otherUserItems[indexPath.row].bookOwner!) { (userName) in
                cell.bookOwner.text = userName
            }
            cell.returnButton.isHidden = true
        }
        return cell
    }
    
    
    //This method add target when button is added in Notification Cell
    func addButtonTargetAndSetTagValue (tableCell : HoldBookTableViewCell, index : Int) {
        
        //Assigning target when Return button is pressed, it will call connected() method.
        tableCell.returnButton.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        
        //Tag will hold the value of idexPath.row
        tableCell.returnButton.tag = index
    }
    
    //This object function will be called when user press Accept or Decline button
    @objc func connected(sender: UIButton){
        //setting sender's tag, which holds indexpath.row
        indexRow = sender.tag
    }
    
    func returnBookPressed(indexRow : Int) {
        print("line number \(String(describing: indexRow))")
        
        let reciversEmail = (currentUserItems[indexRow].bookOwner)!
        let bookName = (currentUserItems[indexRow].bookName)!
        let bookAuthor = (currentUserItems[indexRow].author)!
        let sendersEmail = authInstance.getCurrentUserEmail()
        
        databaseInstance.getUserName(usersEmail: sendersEmail) { (userName) in
            
            //Adding a notificartion to return a book. And returnRequested field inside Firestore: Users/userEmail...
            self.databaseInstance.addReturnBookRequestNotification(reciversEmail: reciversEmail, sendersEmail: sendersEmail,sendersUserName: userName, bookName: bookName, bookAuthor: bookAuthor)
            
            //Changing returnRequested status inside CoreData
            self.currentUserItems[indexRow].returnRequested = true
            self.coreDataClassInstance.saveContext()
            
        }
        
    }
    
    
    //MARK: Model Manipulation Methods
    
    func loadItems() {
        do {
            if !authInstance.isItOtherUsersPage(userEmail: currentUser!){
                currentUserItems = try coreDataClassInstance.getContext().fetch(requestForHoldBooks)
            } else {
                if otherUserItems.count == 0 {
                    //print("printing current user: \(currentUser as String)")
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
    }
}
