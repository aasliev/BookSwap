//
//  NotificatonsScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class NotificatonsScreen: UITableViewController, NotificationCellDelegate {

    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let processingBarInstance = SVProgressHUDClass.shared
    
    var indexRow : Int?
    
    var notificationDictionary : Dictionary<Int , Dictionary <String, Any> > = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        processingBarInstance.displayProgressBar()
        tableView.rowHeight = 100
        
        //this disables the selection of row.
        //When user clicks on book, no selection will highlight any row
        tableView.allowsSelection = false
        
        databaseInstance.getNotifications(usersEmail: authInstance.getCurrentUserEmail()) { (dict) in
            print("Dictionary is: \(dict as AnyObject)")

            self.notificationDictionary = dict
            self.tableView.reloadData()
            
            //Dismissing Progressing Screen
            self.processingBarInstance.dismissProgressBar()
            
        }

    }
    
    //NotificationCellDelegate Method. will be called when any button will be pressed
    func notificationButtonPressed(ifAccepted : Bool, indexRow : Int) {
        
        //IfAccepted will be true if user press Accept. false if presses decline
        if(ifAccepted) {
            
            let currentUser = authInstance.getCurrentUserEmail()
            let requestersEmail = notificationDictionary[indexRow]![databaseInstance.SENDERS_EMAIL_FIELD] as! String
            let requesterUserName = notificationDictionary[indexRow]![databaseInstance.SENDERS_USER_NAME_FIELD] as! String
            
            
            //Checking for type of request. If returns true, that means it's BookSwap request
            if (checkIfNotificationForBookSwap(index: indexRow)) {
                let bookName = notificationDictionary[indexRow]![databaseInstance.BOOKNAME_FIELD] as! String
                let bookAuthor = notificationDictionary[indexRow]![databaseInstance.AUTHOR_FIELD] as! String
                
                databaseInstance.addHoldingBookToPerformBookSwap (bookOwnerEmail: currentUser, bookRequester: requestersEmail, bookName: bookName, bookAuthor: bookAuthor)
                
                //Making changes in CoreData. This changes holder's email from logged in user to requester's email. and makes bookStatus false
                CoreDataClass.sharedCoreData.changeBookStatusAndHolder(bookName: bookName, bookAuthor: bookAuthor, bookHolder: requestersEmail, status: false)
                
                //Remove the Book Swap request from firestore
                databaseInstance.removeBookSwapRequestNotification(sendersEmail: requestersEmail, reciverEmail: currentUser, bookName: bookName, bookAuthor: bookAuthor)
                
                
                
            } else if (checkIfNotificationForFriendRequest(index: indexRow)) {
                
                databaseInstance.addNewFriend(currentUserEmail: currentUser, friendsEmail: requestersEmail, friendsUserName: requesterUserName)
                
                databaseInstance.getNumberOfSwaps(usersEmail: requestersEmail) { (numOfSwaps) in
                    
                    CoreDataClass.sharedCoreData.addAFriendIntoCoreData(friendsEmail: requestersEmail, friendsUserName: requesterUserName, numberOfSwaps: "\(numOfSwaps)")
                }
                
                //Remove Friend request from Firestore
                databaseInstance.removeFriendRequestNotification(sendersEmail: requestersEmail, reciverEmail: currentUser)
                
            } else if (checkIfNotificationForReturningABook(index: indexRow)) {
                
                let bookName = notificationDictionary[indexRow]![databaseInstance.BOOKNAME_FIELD] as! String
                let bookAuthor = notificationDictionary[indexRow]![databaseInstance.AUTHOR_FIELD] as! String
                
                databaseInstance.successfullyReturnedHoldingBook(currentUser: authInstance.getCurrentUserEmail(), sendersEmail: requestersEmail, bookName: bookName, bookAuthor: bookAuthor)
                
                databaseInstance.removeBookSwapRequestNotification(sendersEmail: requestersEmail, reciverEmail: currentUser, bookName: bookName, bookAuthor: bookAuthor)
                
                CoreDataClass.sharedCoreData.changeBookStatusAndHolder(bookName: bookName, bookAuthor: bookAuthor, bookHolder: authInstance.getCurrentUserEmail(), status: true)
            }
            
        }
        
        
        notificationDictionary.removeValue(forKey: indexRow)
        //print("Dict: \(notificationDictionary as AnyObject)")
        tableView.reloadData()
        
        //Dismissing Progressing Screen
        processingBarInstance.dismissProgressBar()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationDictionary.count

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
        
        //this if statment chaneck if index value has data in it.
        if notificationDictionary[indexPath.row] == nil {return cell}
        
        //This line connects NotificationCellDelegate.
        cell.delegate = self
        
        
        //Method is used to keep track of indexPath.row for each button
        addButtonTargetAndSetTagValue(tableCell: cell, index: indexPath.row)
        
        print("Index: \(indexPath.row)")
        //Getting User Name of the user who sent the reruest
        let senderUserName = notificationDictionary[indexPath.row]![databaseInstance.SENDERS_USER_NAME_FIELD] as! String
        
        
       
        //Checking if request is for BookSwap
        if checkIfNotificationForBookSwap(index: indexPath.row) {
            //Getting book name and author from notificationDictionary
            let bookName = notificationDictionary[indexPath.row]![databaseInstance.BOOKNAME_FIELD] as! String
            let bookAuthor = notificationDictionary[indexPath.row]![databaseInstance.AUTHOR_FIELD] as! String
            
            //It will create cell for book swap request and return the cell
            return assignBookRequestNotification(cell: cell, sender: senderUserName, bookName: bookName, bookAuthor: bookAuthor)
        } else if (checkIfNotificationForFriendRequest(index: indexPath.row)){
            
            //If it is not for book swap, it is a friend request. As of now, we only have two types of requests.
            //It will create cell for friend request and return the cell
            return assignFriendReqestNotification(cell: cell, sender: senderUserName)
        
        } else /* if (checkIfNotificationForReturningABook(index: indexPath.row)) */{
            
            //Getting book name and author from notificationDictionary
            let bookName = notificationDictionary[indexPath.row]![databaseInstance.BOOKNAME_FIELD] as! String
            let bookAuthor = notificationDictionary[indexPath.row]![databaseInstance.AUTHOR_FIELD] as! String
            
            return assignReturningABookNotification(cell: cell, sender: senderUserName, bookName: bookName, bookAuthor: bookAuthor)
        }
        
    }
    
    
    //This method add target when button is added in Notification Cell
    func addButtonTargetAndSetTagValue (tableCell : NotificationCell, index : Int) {
        
        //Assigning target when Accept or Decline button is pressed, it will call connected() method.
        tableCell.acceptButton.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        tableCell.declineButton.addTarget(self, action: #selector(connected(sender:)), for: .touchUpInside)
        
        //Tag will hold the value of idexPath.row
        tableCell.acceptButton.tag = index
        tableCell.declineButton.tag = index
    }
    
    
    //This object function will be called when user press Accept or Decline button
    @objc func connected(sender: UIButton){
        //setting sender's tag, which holds indexpath.row
        self.indexRow = sender.tag
    }
    
    
    
    private func assignBookRequestNotification (cell : NotificationCell, sender : String, bookName: String, bookAuthor : String) -> NotificationCell {
        
        cell.notificationTextLabel.text = "Book Swap request from \(sender). For \(bookName) by \(bookAuthor)."
        
        return cell
    }
    
    
    private func assignFriendReqestNotification (cell : NotificationCell, sender : String) -> NotificationCell{
        
        cell.notificationTextLabel.text = "Received friend request from \(sender)."
        
        return cell
    }
    
    private func assignReturningABookNotification (cell : NotificationCell, sender : String, bookName: String, bookAuthor : String) -> NotificationCell{
        
        cell.notificationTextLabel.text = "Book return request from \(sender). For \(bookName) by \(bookAuthor)."
        
        return cell
    }
    
    
    private func checkIfNotificationForBookSwap (index : Int) -> Bool {
    
        let notificationType = notificationDictionary[index]![databaseInstance.NOTIFICATION_TYPE] as! String
        
        return databaseInstance.BOOKSWAP_REQUEST_NOTIFICATION == notificationType
    }
    
    private func checkIfNotificationForFriendRequest (index : Int) -> Bool {
        
        let notificationType = notificationDictionary[index]![databaseInstance.NOTIFICATION_TYPE] as! String
        
        return databaseInstance.FRIEND_REQUEST_NOTIFICATION == notificationType
    }
    
    private func checkIfNotificationForReturningABook (index : Int) -> Bool {
        
        let notificationType = notificationDictionary[index]![databaseInstance.NOTIFICATION_TYPE] as! String
        
        return databaseInstance.RETURN_BOOK_REQUEST_NOTIFICATION == notificationType
    }


}
