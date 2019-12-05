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
    var itemArray = [WishList]()
    var otherWishList = [OthersWishList]()
    
    //context of Core Data file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        tableView.rowHeight = 80
        tableView.refreshControl = refresher
    }
    
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authInstance.isOtherUserEmpty() ?  itemArray.count : otherWishList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishCell", for: indexPath) as! WishListTableViewCell
        
        if authInstance.isOtherUserEmpty(){
            
            cell.nameOfTheBook?.text = itemArray[indexPath.row].bookName
            cell.authorOfTheBook?.text = itemArray[indexPath.row].author
            
        } else {
            
            cell.nameOfTheBook?.text = otherWishList[indexPath.row].bookName
            cell.authorOfTheBook?.text = otherWishList[indexPath.row].author
        }
        
        cell.delegate = self
        return cell
    }
    
    
    //MARK: - Model Manipulation Methods
    @objc func loadItems(with request: NSFetchRequest<WishList> = WishList.fetchRequest()) {
        do {
            
            //checks which user is currently on the WishList page
            //NOTE: Other User will be true if user open someone else's WishList
            if authInstance.isOtherUserEmpty() {
                
                itemArray = try context.fetch(request)
            } else {
                
                databaseIstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.otherUser, trueForOwnedBookFalseForWishList: false) { (dataDictionary) in
                    
                    self.loadDataForOtherUser(dict: dataDictionary)
                }
            }
            
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    //Loads the data inside OthersWishList array, which is received from Firestore
    func loadDataForOtherUser(dict : Dictionary<Int  , Dictionary<String  , Any>>) {
        
        //Clearing the data stored inside Core Data file
        self.coreDataClassInstance.resetOneEntitie(entityName: "OthersWishList")
        
        //Clearing the array which holds objects of 'OthersOwnedBook'
        self.otherWishList.removeAll()
        
        for (_, data) in dict {
            
            let newWhishListBook = OthersWishList(context: self.context)
            newWhishListBook.bookName = (data[self.databaseIstance.BOOKNAME_FIELD] as! String)
            newWhishListBook.author = (data[self.databaseIstance.AUTHOR_FIELD] as! String)
            
            self.otherWishList.append(newWhishListBook)
        }
        
        self.coreDataClassInstance.saveContext()
        
        print("This is DICT: ", dict as AnyObject)
        self.tableView.reloadData()
        
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
        self.tableView.reloadData()
        
    }
}


//MARK: Search

extension WishListScreen: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<WishList> = WishList.fetchRequest()
        request.predicate = NSPredicate(format: "bookName CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
        
        loadItems(with: request)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadItems()
            tableView.reloadData()
        }
    }
    
}

//MARK: SwipeCellKit
extension WishListScreen: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
   
        //Checks if user is on someone else's WishList page. If yes, disable the feature of swiping left to delete and right for moving from WishList to OwnedBook..
        if (!authInstance.isOtherUserEmpty()) { return nil }
        
        guard orientation == .right else {
            let moreAction = SwipeAction(style: .default, title: "Move") { action, indexPath in
                //move book from wishList to Owned books
                
                let newOwnedBook = OwnedBook(context: self.context)
                newOwnedBook.author = self.itemArray[indexPath.row].author
                newOwnedBook.bookName = self.itemArray[indexPath.row].bookName
                newOwnedBook.status = true
                
                //This will move the selected book from WishList into OwnedBook
                self.databaseIstance.moveWishListToOwnedBook (currentUserEmail: self.authInstance.getCurrentUserEmail()!, bookName: self.itemArray[indexPath.row].bookName!, bookAuthor: self.itemArray[indexPath.row].author!)
                
                
                //deleting data from persistence container
                self.context.delete(self.itemArray[indexPath.row])
                
                //deleting data from itemArray and saving Coredata context
                self.itemArray.remove(at: indexPath.row)
                CoreDataClass.sharedCoreData.saveContext()
                
            }
            moreAction.image = UIImage(named: "More-icon")
            
            return [moreAction]
            
        }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            // handle action by updating model with deletion
            self.context.delete(self.itemArray[indexPath.row])
            
            //Using itemArray gettin name of book and book's author.
            self.databaseIstance.removeWishListBook(bookName: self.itemArray[indexPath.row].bookName!, bookAuthor: self.itemArray[indexPath.row].author!)
            
            //Removing the data from itemArray
            self.itemArray.remove(at: indexPath.row)
            CoreDataClass.sharedCoreData.saveContext()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "trash-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    
}

