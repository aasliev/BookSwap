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
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //checks if it is not logged in user's whishListScreen, if true
        //it returns count of otherWishList elements. If false, itemArray's count
        return !authInstance.isItOtherUsersPage(userEmail: usersHistory!) ?  currentUserHistory.count : otherUsersHistory.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        if !authInstance.isItOtherUsersPage(userEmail: usersHistory!) {
            
            cell.sendersEmail?.text = currentUserHistory[indexPath.row].sendersEmail
            cell.reciversEmail?.text = currentUserHistory[indexPath.row].reciversEmail
            cell.bookData?.text = ("\(currentUserHistory[indexPath.row].bookName ?? "BookName") by \((currentUserHistory[indexPath.row].authorName) ?? "BookAuthor")")
            cell.inProcessLbl?.text = currentUserHistory[indexPath.row].inProcessStatus ? "In Process" : "Completed"
            
            if (indexPath.row == (currentUserHistory.count - 1)) {
                progressBarInstance.dismissProgressBar()
            }
            
        } else {
            //data will be recived firestore in a dictionary
            cell.sendersEmail?.text = "Email of Left User (Sender)"
            cell.reciversEmail?.text = "Email of Right User (Reciver)"
            cell.bookData?.text = "bookName-bookAutor"
            cell.inProcessLbl?.text = "Recive Boolean if yes print 'In Process', otherwise 'Completed'"
            
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
            } else {
                
                if (otherUsersHistory.count == 0) {
                    databaseIstance.getHistoryData(usersEmail: usersHistory!) { (dataDictionary) in
                        self.loadDataForOtherUser(dict: dataDictionary)
                    }
                } else {}
            }
            tableView.reloadData()
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
