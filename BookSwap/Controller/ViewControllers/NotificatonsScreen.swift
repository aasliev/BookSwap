//
//  NotificatonsScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class NotificatonsScreen: UITableViewController {

    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    var notificationDictionary : Dictionary<Int , Dictionary <String, Any> > = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 100
        
        databaseInstance.getNotifications(usersEmail: authInstance.getCurrentUserEmail()) { (dict) in
            print("Dictionary is: \(dict as AnyObject)")
            
//            for (index,data) in dict {
//                self.notificationDictionary[index] = data
//            }
            self.notificationDictionary = dict
            self.tableView.reloadData()
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("notificationDictionary.count \(notificationDictionary.count)")
        return notificationDictionary.count

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
        
        let senderUserName = notificationDictionary[indexPath.row]![databaseInstance.SENDERS_USER_NAME_FIELD] as! String
       
        if checkIfNotificationForBookSwap(index: indexPath.row) {
            
            let bookName = notificationDictionary[indexPath.row]![databaseInstance.BOOKNAME_FIELD] as! String
            let bookAuthor = notificationDictionary[indexPath.row]![databaseInstance.AUTHOR_FIELD] as! String
            
            return assignBookRequestNotification(cell: cell, sender: senderUserName, bookName: bookName, bookAuthor: bookAuthor)
        } else {
            return assignFriendReqestNotification(cell: cell, sender: senderUserName)
        }
    }
    
    
    private func assignBookRequestNotification (cell : NotificationCell, sender : String, bookName: String, bookAuthor : String) -> NotificationCell {
        
        cell.notificationTextLabel.text = "Book Swap request from \(sender). For \(bookName) by \(bookAuthor)."
        
        return cell
    }
    
    
    private func assignFriendReqestNotification (cell : NotificationCell, sender : String) -> NotificationCell{
        
        cell.notificationTextLabel.text = "You have received friend request from \(sender)."
        
        return cell
    }
    
    
    private func checkIfNotificationForBookSwap (index : Int) -> Bool {
    
        let notificationType = notificationDictionary[index]![databaseInstance.NOTIFICATION_TYPE] as! String
        
        return databaseInstance.BOOKSWAP_REQUEST_NOTIFICATION == notificationType
    }


}
