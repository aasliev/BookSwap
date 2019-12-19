//
//  OwnedBookScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class OwnedBookScreen: UITableViewController {
    
    //Array which takes objects of OwnedBook
    var currentUserItems = [OwnedBook]()
    var otherUserItems = [OthersOwnedBook]()
    
    var usersBookShelf : String?
    
    //NSFetchRequest
    var requestForBooks: NSFetchRequest<OwnedBook> = OwnedBook.fetchRequest()
    var requestForOthersFriendsBooks : NSFetchRequest<OthersOwnedBook> = OthersOwnedBook.fetchRequest()
    
    //context of Core Data file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData

    override func viewDidLoad() {
        super.viewDidLoad()
       
        //setting usersBookShelf equals to email of usersScreen
        //Whis was added inside ProfileScreen/prepareSegue
        usersBookShelf = authInstance.getUsersScreen()
        
        tableView.rowHeight = 120
        tableView.refreshControl = refresher
        
        //this disables the selection of row.
        //When user clicks on book, no selection will highlight any row
        tableView.allowsSelection = false
//        if !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!) {
//            loadItems()
//        } else {
//            loadItemsOtherUser()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        loadItems()
    }
    
    
    //MARK: TableView DataSource Methods
    
    //This method will be called when user selects or clicks on any row inside table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        //to create click animation
        //        tableView.deselectRow(at: indexPath, animated: true)

        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("This is otherUser.count: \(otherUserItems.count)")
        return !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!) ?  currentUserItems.count : otherUserItems.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "booksCell", for: indexPath) as! BooksTableViewCell
        
        if !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!){
            
            
            cell.nameOfTheBook?.text = currentUserItems[indexPath.row].bookName
            cell.authorOfTheBook?.text = currentUserItems[indexPath.row].author
            cell.swap.isHidden = true
            if !(currentUserItems[indexPath.row].status) {
                cell.nameOfTheBook.textColor = UIColor.init(white: 1, alpha: 0.5)
                cell.authorOfTheBook.textColor = UIColor.init(white: 1, alpha: 0.5)
            }
        
        } else {
            
            cell.nameOfTheBook?.text = otherUserItems[indexPath.row].bookName
            cell.authorOfTheBook?.text = otherUserItems[indexPath.row].author
            
            //If book status is true, it will show the book by making 'isHidden' = false
            //or if book status is false, it will hide the swap button
            cell.swap.isHidden = !(otherUserItems[indexPath.row].status)
        }
       
        cell.delegate = self
        return cell
    }

    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        do {
            //checks which user is currently on the FriendsList page
            //NOTE: Other User will be true if user open someone else's WishList
            if !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!) {
                requestForBooks.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
                currentUserItems = try context.fetch(requestForBooks)
            } else {
                //print("otherUserCount: = \(otherUserItems.count)")
                if (otherUserItems.count == 0) {
                    databaseIstance.getListOfOwnedBookOrWishList (usersEmail: usersBookShelf!, trueForOwnedBookFalseForWishList: true) { (dataDictionary) in
                        self.loadDataForOtherUser(dict: dataDictionary)
                    }
                } else {
                    requestForOthersFriendsBooks.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
                    otherUserItems = try context.fetch(requestForOthersFriendsBooks)
                }
            }
            tableView.reloadData()
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    //Loads the data inside OthersOwnedBook array, which is received from Firestore
    func loadDataForOtherUser(dict : Dictionary<Int  , Dictionary<String  , Any>>) {
        
        //Clearing the data stored inside Core Data file
        coreDataClassInstance.resetOneEntity(entityName: "OthersOwnedBook")
        
        //Clearing the array which holds objects of 'OthersWishList'
        otherUserItems.removeAll()
        
        for (_, data) in dict {
            
            //creating an object of OthersOwnedBook with the context of Core Data
            let newOwnedBook = OthersOwnedBook(context: self.context)
            
            //adding data from dictionary, data holds information such as bookName, author and status
            newOwnedBook.bookName = (data[self.databaseIstance.BOOKNAME_FIELD] as! String)
            newOwnedBook.author = (data[self.databaseIstance.AUTHOR_FIELD] as! String)
            newOwnedBook.status = data[self.databaseIstance.BOOK_STATUS_FIELD] as! Bool
            
            //Appending inside otherUser array
            otherUserItems.append(newOwnedBook)
        }
        
        //saving all the changes made in core data
        coreDataClassInstance.saveContext()
        
        //reloading the table view to show the latest result
        tableView.reloadData()
        
    }
    
    
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
        self.viewDidLoad()
        tableView.reloadData()
    }
}






//MARK: Search

extension OwnedBookScreen: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //creating NSPredicate which finds keyword in bookName and author field
        let nsPredicate = NSPredicate(format: "(bookName CONTAINS[cd] %@) OR (author CONTAINS[cd] %@)", searchBar.text!, searchBar.text!)
        
        //Checking if otherUser is empty
        if (!authInstance.isItOtherUsersPage(userEmail: usersBookShelf!)) {
            
            //creating request for current user's own OwnedBook page
            requestForBooks.predicate = nsPredicate
        } else {
            
            //creating reqest for other user's OwnedBook page
            requestForOthersFriendsBooks.predicate = nsPredicate
        }
        loadItems()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            //loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            requestForBooks = OwnedBook.fetchRequest()
            requestForOthersFriendsBooks = OthersOwnedBook.fetchRequest()
            loadItems()
            tableView.reloadData()
        }
    }
    
}





//MARK: SwipeCellKit
extension OwnedBookScreen: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if (!authInstance.isItOtherUsersPage(userEmail: usersBookShelf!)) {
            guard orientation == .right else { return nil }
        } else {
            //databaseIstance.addHoldingBook(bookOwnerEmail: usersBookShelf!, bookName: self.otherUser[indexPath.row].bookName!, bookAuthor: otherUser[indexPath.row].author!)
            return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            //create UIAlert
            let alert = UIAlertController(title: "Delete Book", message: "Do you want to Delete the Book?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                 // handle action by updating model with deletion
                self.context.delete(self.currentUserItems[indexPath.row])
                
                //Using itemArray gettin name of book and book's author.
                self.databaseIstance.removeOwnedBook(bookName: self.currentUserItems[indexPath.row].bookName!, bookAuthor: self.currentUserItems[indexPath.row].author!)
                
                //Removing the data from itemArray
                self.currentUserItems.remove(at: indexPath.row)
                self.coreDataClassInstance.saveContext()
                tableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-icon")
        return [deleteAction]
    }
}
