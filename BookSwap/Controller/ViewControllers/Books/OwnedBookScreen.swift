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
    
    var itemArray = [OwnedBook]()
    var otherUser = [OthersOwnedBook]()
    
    lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
        
        return refreshControl
    }()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print("inside ownedBookScreen")
       // loadItems()
        tableView.rowHeight = 80
        tableView.refreshControl = refresher

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        loadItems()
        self.tableView.reloadData()
    }
    
    @objc func refreshItems(){
        
        self.loadItems()
        let deadLine = DispatchTime.now() + .milliseconds(500)
        DispatchQueue.main.asyncAfter(deadline: deadLine) {
            self.refresher.endRefreshing()
        }
        self.tableView.reloadData()
        
    }

    
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
            //let request = request
            //request.sortDescriptors = [NSSortDescriptor(key: "bookName", ascending: true)]
            if authInstance.isOtherUserEmpty() {
                
                itemArray = try context.fetch(request)
            } else {
                
                databaseIstance.getListOfOwnedBookOrWishList(usersEmail: authInstance.otherUser, trueForOwnedBookFalseForWishList: true) { (dict) in
                    
                    CoreDataClass.sharedCoreData.resetOneEntitie(entityName: "OthersOwnedBook")
                    
                    for (_, data) in dict {
                        
                        let newOwnedBook = OthersOwnedBook(context: self.context)
                        newOwnedBook.bookName = (data[self.databaseIstance.BOOKNAME_FIELD] as! String)
                        newOwnedBook.author = (data[self.databaseIstance.AUTHOR_FIELD] as! String)
                        newOwnedBook.status = data[self.databaseIstance.BOOK_STATUS_FIELD] as! Bool
                        
                        self.otherUser.append(newOwnedBook)
                    }
                    
                    CoreDataClass.sharedCoreData.saveContext()
                    
                    print("This is DICT: ", dict as AnyObject)
                    self.tableView.reloadData()
                }
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
        
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
