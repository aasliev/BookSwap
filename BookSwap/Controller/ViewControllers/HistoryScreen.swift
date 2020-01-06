//
//  HistoryScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import CoreData

class HistoryScreen: UITableViewController {

    @IBOutlet weak var historyNavigationItem: UINavigationItem!

    //context of Core Data file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Array which takes objects of WishList
    var currentUserHistory = [History]()
    var otherUsersHistory : Dictionary <Int, Dictionary<String, Any>> = [:]
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    let progressBarInstance = SVProgressHUDClass.shared
    let commonFunctionsInstance = CommonFunctions.sharedCommonFunction
    //Request for search result
    var requestForHistory : NSFetchRequest<History> = History.fetchRequest()
    
    //Variable to keep track of who's screen is user on
    var usersHistory : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "History"
        
        //gets the email of user passed from prfileScreen
        usersHistory = authInstance.getUsersScreen()
        
        tableView.rowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.historyNavigationItem.title = "History"
        loadHistory()
        if (commonFunctionsInstance.getPlistData().SVCounterHistory > 0){
            progressBarInstance.displayMessage(message: "Swipe Left for Holding List")
            commonFunctionsInstance.decrementData(entityName: commonFunctionsInstance.HISTORY_ENTITY)
        }
        
        databaseIstance.getListofHistoryNotAddedInCoreData(userEmail: authInstance.getCurrentUserEmail()) { (dict) in
            print("Result of CoreData Search inside History: \(dict as AnyObject)")
            //self.coreDataClassInstance.addFriendList(friendList: dict)
            self.loadHistory()
        }
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //checks if it is not logged in user's whishListScreen, if true
        //it returns count of otherWishList elements. If false, itemArray's count
        let numberOfRows = !authInstance.isItOtherUsersPage(userEmail: usersHistory!) ?  currentUserHistory.count : otherUsersHistory.count
        
        return numberOfRows
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        if !authInstance.isItOtherUsersPage(userEmail: usersHistory!) {
            databaseIstance.getUserName(usersEmail: currentUserHistory[indexPath.row].sendersEmail!) { (userName) in
                cell.sendersEmail?.text = userName
            }
            
            databaseIstance.getUserName(usersEmail: currentUserHistory[indexPath.row].reciversEmail!) { (userName) in
                cell.reciversEmail?.text = userName
            }
            
            cell.bookData?.text = ("\(currentUserHistory[indexPath.row].bookName ?? "BookName") by \((currentUserHistory[indexPath.row].authorName) ?? "BookAuthor")")
            cell.inProcessLbl?.text = currentUserHistory[indexPath.row].inProcessStatus ? "In Process" : "Completed"
            
        } else {
            //data will be recived firestore in a dictionary
            let sendersEmail = otherUsersHistory[indexPath.row]![databaseIstance.SENDERS_EMAIL_FIELD] as! String
            let reciversEmail = otherUsersHistory[indexPath.row]![databaseIstance.RECEIVERS_EMAIL_FIELD] as! String
            let bookName = otherUsersHistory[indexPath.row]![databaseIstance.BOOKNAME_FIELD] as! String
            let bookAuthor = otherUsersHistory[indexPath.row]![databaseIstance.AUTHOR_FIELD] as! String
            let isProcessingStatus = otherUsersHistory[indexPath.row]![databaseIstance.SWAP_IN_PROCESS] as! Bool
            
            databaseIstance.getUserName(usersEmail: sendersEmail) { (userName) in
                cell.sendersEmail?.text = userName
            }
            databaseIstance.getUserName(usersEmail: reciversEmail) { (userName) in
                cell.reciversEmail?.text = userName
            }
            
            cell.bookData?.text = "\(bookName) by \(bookAuthor)"
            cell.inProcessLbl?.text = isProcessingStatus ? "In Proces" : "Completed"
            
            if (indexPath.row == (otherUsersHistory.count - 1)) {
                progressBarInstance.dismissProgressBar()
            }
        }
        
        
        return cell
    }
    
    func loadHistory() {
        do {
            //checks which user is currently on the History page
            //NOTE: Other User will be true if user open someone else's History
            if !authInstance.isItOtherUsersPage(userEmail: usersHistory!) {
                
                requestForHistory.sortDescriptors = [NSSortDescriptor(key: "assignNumber", ascending: false)]
                currentUserHistory = try coreDataClassInstance.getContext().fetch(History.fetchRequest())
                tableView.reloadData()
                progressBarInstance.dismissProgressBar()
            } else {
                
                if (otherUsersHistory.count == 0) {
                    databaseIstance.getHistoryData(usersEmail: usersHistory!) { (dataDictionary) in
                        self.loadDataForOtherUser(dict: dataDictionary)
                        self.tableView.reloadData()
                        self.progressBarInstance.dismissProgressBar()
                    }
                } else {}
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func loadDataForOtherUser (dict : Dictionary<Int  , Dictionary<String  , Any>>) {
        
        //Clearing the array which holds objects of 'OthersOwnedBook'
        otherUsersHistory.removeAll()
        
        otherUsersHistory = dict
        
    }
    
}
