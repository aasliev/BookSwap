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
import NotificationCenter

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
    let progressBarInstance = SVProgressHUDClass.shared
    let commonFunctionsInstance = CommonFunctions.sharedCommonFunction
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        //setting usersBookShelf equals to email of usersScreen
        //Whis was added inside ProfileScreen/prepareSegue
        usersBookShelf = authInstance.getUsersScreen()
        //print("usersBookShelf:  \(usersBookShelf)")
        tableView.rowHeight = 120
        tableView.refreshControl = refresher

        //this disables the selection of row.
        //When user clicks on book, no selection will highlight any row
        tableView.allowsSelection = false
        
        let adjustForTabbarInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.tabBarController!.tabBar.frame.height, right: 0)
        self.tableView.contentInset = adjustForTabbarInsets
        self.tableView.scrollIndicatorInsets = adjustForTabbarInsets
        
        //adding an observer for reloading data
        NotificationCenter.default.addObserver(self, selector: #selector(refreshItems), name: .didReceiveData, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        loadItems()
        
        //Get's data from pList with the key 'SVCounterBook'. If it is 0 that means user is opening Bookshelf page for the first time
        if (commonFunctionsInstance.getPlistData().SVCounterBook > 0){

            //If 'SVCounterBook is 0,  user will see a message.
            progressBarInstance.displayMessage(message: "Swipe Left for Wish List")
            commonFunctionsInstance.decrementData(entityName: commonFunctionsInstance.BOOK_ENTITY)
        }
        
        if (!authInstance.isItOtherUsersPage(userEmail: usersBookShelf!)){
            databaseIstance.getListofOwnedBookNotAddedInCoreData(userEmail: authInstance.getCurrentUserEmail()) { (dict) in
                print("Result of CoreData Search inside OwnedBooks: \(dict as AnyObject)")
                self.coreDataClassInstance.updateOwnedBook(dictionary: dict)
                self.loadItems()
            }
        }
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
        
        cell.swap.setTitle("Swap", for: .normal)
        
        if !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!){
            
            
            cell.nameOfTheBook?.text = currentUserItems[indexPath.row].bookName
            cell.authorOfTheBook?.text = currentUserItems[indexPath.row].author
            cell.swap.isHidden = true
            
            //If User holds the book 'currentUserItems' will be true
            if (currentUserItems[indexPath.row].status) {
                cell.nameOfTheBook.textColor = UIColor.white
                cell.authorOfTheBook.textColor = UIColor.white
                cell.holderLabel.isHidden = true
                
            } else {
                
                cell.nameOfTheBook.textColor = UIColor.init(white: 1, alpha: 0.5)
                cell.authorOfTheBook.textColor = UIColor.init(white: 1, alpha: 0.5)
                cell.holderLabel.isHidden = false
                
                //Getting userName of holder. Holder field of currentUserItem holds email of person holding the book
                databaseIstance.getUserName(usersEmail: currentUserItems[indexPath.row].holder!) { (userName) in
                    cell.holderLabel?.text = userName
                }
                
                
            }
        
        } else {
            
            cell.nameOfTheBook?.text = otherUserItems[indexPath.row].bookName
            cell.authorOfTheBook?.text = otherUserItems[indexPath.row].author
            
            //If book status is true, it will show the book by making 'isHidden' = false
            //or if book status is false, it will hide the swap button
            cell.swap.isHidden = !(otherUserItems[indexPath.row].status)
            
            //Getting userName of holder. Holder field of currentUserItem holds email of person holding the book
            if (!otherUserItems[indexPath.row].status) {
                databaseIstance.getUserName(usersEmail: otherUserItems[indexPath.row].holder!) { (userName) in
                    cell.holderLabel?.text = userName
                }
            }

            cell.holderLabel.isHidden = (otherUserItems[indexPath.row].status)
            
            
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
                        //Reseting the tableView.
                        self.tableView.reloadData()
                    }
                } else {
                    requestForOthersFriendsBooks.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
                    otherUserItems = try context.fetch(requestForOthersFriendsBooks)
                }
            }
            
            //Reseting the tableView.
            tableView.reloadData()
            progressBarInstance.dismissProgressBar()
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
            newOwnedBook.holder = (data[self.databaseIstance.BOOK_HOLDER_FIELD] as! String)
            //Appending inside otherUser array
            otherUserItems.append(newOwnedBook)
        }
        
        //saving all the changes made in core data
        coreDataClassInstance.saveContext()
        
    }
    
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
        
        return refreshControl
    }()
    
    
    @objc func refreshItems(){
        
        
        let deadLine = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            self.refresher.endRefreshing()
        }
        self.loadItems()
        //self.viewDidLoad()
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



extension Notification.Name {
    static let didReceiveData = Notification.Name("didReceiveData")
}
