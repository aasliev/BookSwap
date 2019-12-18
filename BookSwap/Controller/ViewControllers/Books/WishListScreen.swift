//
//  WishListScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class WishListScreen: UITableViewController {

    //Array which takes objects of WishList
    var currentUserItems = [WishList]()
    var otherUserItems = [OthersWishList]()
    
    //context of Core Data file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    
    //Variable to keep track of who's screen is user on
    var usersWishList : String?
    
    //Request for search result
    var requestForWishList : NSFetchRequest<WishList> = WishList.fetchRequest()
    var requestForOthersWishList : NSFetchRequest<OthersWishList> = OthersWishList.fetchRequest()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //gets the email of user passed from prfileScreen
        usersWishList = authInstance.getUsersScreen()
        tableView.rowHeight = 120
        tableView.refreshControl = refresher
        
        //this disables the selection of row.
        //When user clicks on book, no selection will highlight any row
        tableView.allowsSelection = false
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadItems()
    }
    
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //checks if it is not logged in user's whishListScreen, if true
        //it returns count of otherWishList elements. If false, itemArray's count
        return !authInstance.isItOtherUsersPage(userEmail: usersWishList!) ?  currentUserItems.count : otherUserItems.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! WishListTableViewCell
        
        if !authInstance.isItOtherUsersPage(userEmail: usersWishList!) {
            
            cell.nameOfTheBook?.text = currentUserItems[indexPath.row].bookName
            cell.authorOfTheBook?.text = currentUserItems[indexPath.row].author
            
        } else {
            
            cell.nameOfTheBook?.text = otherUserItems[indexPath.row].bookName
            cell.authorOfTheBook?.text = otherUserItems[indexPath.row].author
        }
        
        cell.delegate = self
        return cell
    }
    
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        do {
            //checks which user is currently on the FriendsList page
            //NOTE: Other User will be true if user open someone else's WishList
            if !authInstance.isItOtherUsersPage(userEmail: usersWishList!) {
                requestForWishList.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
                currentUserItems = try context.fetch(requestForWishList)
            } else {
                
                if (otherUserItems.count == 0) {
                    databaseIstance.getListOfFriends (usersEmail: usersWishList!) { (dataDictionary) in
                        self.loadDataForOtherUser(dict: dataDictionary)
                    }
                } else {
                    requestForOthersWishList.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
                    otherUserItems = try context.fetch(requestForOthersWishList)
                }
            }
            tableView.reloadData()
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    
    
//    //LOAD FUNCTION
//    func loadItems(with request: NSFetchRequest<WishList> = WishList.fetchRequest()) {
//         do {
//            if !authInstance.isItOtherUsersPage(userEmail: usersWishList!) {
//             itemArray = try context.fetch(request)
//            }
//         } catch {
//             print("Error fetching data from context \(error)")
//         }
//
//     }
//    //LOAD FUNCTION FOR OTHER USERS
//    func loadItemsOtherUser(with request: NSFetchRequest<OthersWishList> = OthersWishList.fetchRequest()) {
//        print("Inside the loadItemsOtherUser")
//        do {
//
//            //Making sure the database call is made only once to get data and load it into 'otherUser' array
//            //Logic: if otherUser.count is equals to 0, that means function call (inside if statment) has not been made yet.
//            if (otherWishList.count == 0) {
//                databaseIstance.getListOfOwnedBookOrWishList(usersEmail: usersWishList!, trueForOwnedBookFalseForWishList: true) { (dataDictionary) in
//
//                    //this method sends the data recived in dictionary from Firestore, and place it inside "otherUser" array.
//                    self.loadDataForOtherUser(dict: dataDictionary)
//                }
//            } else {
//
//                //Once user searches anything in search bar, "requestForOthersOwnedBook" holds query.
//                //context.fetch... will fetch result and store it inside otherUser array
//                otherWishList = try context.fetch(request)
//            }
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
//
//    }


    //Loads the data inside OthersWishList array, which is received from Firestore
    func loadDataForOtherUser(dict : Dictionary<Int  , Dictionary<String  , Any>>) {
        
        //Clearing the data stored inside Core Data file
        coreDataClassInstance.resetOneEntitie(entityName: "OthersWishList")
        
        //Clearing the array which holds objects of 'OthersOwnedBook'
        otherUserItems.removeAll()
        
        for (_, data) in dict {
            
            //creating an object of OthersWishList with the context of Core Data
            let newWhishListBook = OthersWishList(context: self.context)
            
            //adding data from dictionary, data holds information such as bookName and author
            newWhishListBook.bookName = (data[self.databaseIstance.BOOKNAME_FIELD] as! String)
            newWhishListBook.author = (data[self.databaseIstance.AUTHOR_FIELD] as! String)
            
            //Appending inside otherUser array
            otherUserItems.append(newWhishListBook)
        }
        
        //saving all the changes made in core data
        coreDataClassInstance.saveContext()
        
        //reloading the table view to show the latest result
        tableView.reloadData()
        
    }
    
//MARK: Refresher
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
        
        return refreshControl
    }()
    
    
    @objc func refreshItems(){
        self.loadItems()
        let deadLine = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            self.refresher.endRefreshing()
        }
        self.tableView.reloadData()
        
    }
}


//MARK: Search

extension WishListScreen: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //creating NSPredicate which finds keyword in bookName and author field
        let nsPredicate = NSPredicate(format: "(bookName CONTAINS[cd] %@) OR (author CONTAINS[cd] %@)", searchBar.text!, searchBar.text!)
        
        //Checking if otherUser is empty
        if (!authInstance.isItOtherUsersPage(userEmail: usersWishList!)) {
            
            //creating request for current user's own WishList page
            requestForWishList.predicate = nsPredicate
        } else {
            
            //creating reqest for other user's WishList page
            requestForOthersWishList.predicate = nsPredicate
        }
        loadItems()
        tableView.reloadData()

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            requestForWishList = WishList.fetchRequest()
            requestForOthersWishList = OthersWishList.fetchRequest()
            loadItems()
            tableView.reloadData()
            
        }
    }
    
}

//MARK: SwipeCellKit
extension WishListScreen: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
   
        //Checks if user is on someone else's WishList page. If yes, disable the feature of swiping left to delete and right for moving from WishList to OwnedBook..
        if (authInstance.isItOtherUsersPage(userEmail: usersWishList!)) { return nil }
        
        guard orientation == .right else {
            let moreAction = SwipeAction(style: .default, title: "Move") { action, indexPath in
                //move book from wishList to Owned books
                
                let newOwnedBook = OwnedBook(context: self.context)
                newOwnedBook.author = self.currentUserItems[indexPath.row].author
                newOwnedBook.bookName = self.currentUserItems[indexPath.row].bookName
                newOwnedBook.status = true
                
                //This will move the selected book from WishList into OwnedBook
                self.databaseIstance.moveWishListToOwnedBook (currentUserEmail: self.authInstance.getCurrentUserEmail(), bookName: self.currentUserItems[indexPath.row].bookName!, bookAuthor: self.currentUserItems[indexPath.row].author!)
                
                
                //deleting data from persistence container
                self.context.delete(self.currentUserItems[indexPath.row])
                
                //deleting data from itemArray and saving Coredata context
                self.currentUserItems.remove(at: indexPath.row)
                CoreDataClass.sharedCoreData.saveContext()
                
            }
            
            moreAction.image = UIImage(named: "More-icon")
            
            return [moreAction]
            
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            //adding alert for delete function
            let alert = UIAlertController(title: "Delete Book", message: "Do you want to Delete the Book?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // handle action by updating model with deletion
                self.context.delete(self.currentUserItems[indexPath.row])
                
                //Using itemArray gettin name of book and book's author.
                self.databaseIstance.removeWishListBook(bookName: self.currentUserItems[indexPath.row].bookName!, bookAuthor: self.currentUserItems[indexPath.row].author!)
                
                //Removing the data from itemArray
                self.currentUserItems.remove(at: indexPath.row)
                CoreDataClass.sharedCoreData.saveContext()
                tableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-icon")
        return [deleteAction]
    }
    
}

