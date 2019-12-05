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
    var itemArray = [OwnedBook]()
    var otherUser = [OthersOwnedBook]()
    
    //context of Core Data file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData

    
    override func viewDidLoad() {
        super.viewDidLoad()
       // loadItems()
        tableView.rowHeight = 80
        tableView.refreshControl = refresher

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadItems()
        self.tableView.reloadData()
    }
    
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("This is otherUser.count: \(otherUser.count)")
        return authInstance.isOtherUserEmpty() ?  itemArray.count : otherUser.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "booksCell", for: indexPath) as! BooksTableViewCell
        
        if authInstance.isOtherUserEmpty(){
            
            cell.nameOfTheBook?.text = itemArray[indexPath.row].bookName
            cell.authorOfTheBook?.text = itemArray[indexPath.row].author
            cell.swap.isHidden = true
        
        } else {
            
            cell.nameOfTheBook?.text = otherUser[indexPath.row].bookName
            cell.authorOfTheBook?.text = otherUser[indexPath.row].author
            cell.swap.isHidden = true
        }
       
        cell.delegate = self
        return cell
    }

    
    //MARK: - Model Manipulation Methods
    func loadItems(with request: NSFetchRequest<OwnedBook> = OwnedBook.fetchRequest()) {
        do {
            
            //checks which user is currently on the OwnedBook page
            //NOTE: Other User will be true if user open someone else's OwnedBook
            if authInstance.isOtherUserEmpty() {
                
                itemArray = try context.fetch(request)
            } else {
                
                databaseIstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.otherUser, trueForOwnedBookFalseForWishList: true) { (dataDictionary) in
                    
                    self.loadDataForOtherUser(dict: dataDictionary)
                }
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    //Loads the data inside OthersOwnedBook array, which is received from Firestore
    func loadDataForOtherUser(dict : Dictionary<Int  , Dictionary<String  , Any>>) {
        
        //Clearing the data stored inside Core Data file
        coreDataClassInstance.resetOneEntitie(entityName: "OthersOwnedBook")
        
        //Clearing the array which holds objects of 'OthersWishList'
        otherUser.removeAll()
        
        for (_, data) in dict {
            
            let newOwnedBook = OthersOwnedBook(context: context)
            newOwnedBook.bookName = (data[databaseIstance.BOOKNAME_FIELD] as! String)
            newOwnedBook.author = (data[databaseIstance.AUTHOR_FIELD] as! String)
            newOwnedBook.status = data[databaseIstance.BOOK_STATUS_FIELD] as! Bool
            
            otherUser.append(newOwnedBook)
        }
        
        coreDataClassInstance.saveContext()
        
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

extension OwnedBookScreen: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<OwnedBook> = OwnedBook.fetchRequest()
        request.predicate = NSPredicate(format: "bookName CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
        
        loadItems(with: request)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            //loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            loadItems()
            tableView.reloadData()
        }
    }
    
}

//MARK: SwipeCellKit
extension OwnedBookScreen: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if (authInstance.isOtherUserEmpty()) {
            guard orientation == .right else { return nil }
        } else { return nil}
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            // handle action by updating model with deletion
            self.context.delete(self.itemArray[indexPath.row])
            
            //Using itemArray gettin name of book and book's author.
            self.databaseIstance.removeOwnedBook(bookName: self.itemArray[indexPath.row].bookName!, bookAuthor: self.itemArray[indexPath.row].author!)
            
            //Removing the data from itemArray
            self.itemArray.remove(at: indexPath.row)
            self.coreDataClassInstance.saveContext()
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
