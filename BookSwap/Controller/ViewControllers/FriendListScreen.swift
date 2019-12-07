//
//  FriendListScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import SwipeCellKit


class FriendListScreen: UITableViewController {

    var itemArray = [Friends]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItems()
        tableView.rowHeight = 80
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        authInstance.otherUser = itemArray[indexPath.row].friendsEmail!
        performSegue(withIdentifier: "friendsProfileView", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        cell.userName?.text = itemArray[indexPath.row].friendsEmail
        cell.add.isHidden = true
        //cell.detailTextLabel = itemArray[indexPath.row].numOfSwaps
        //cell.imageView!.image = UIImage(named: "bookcrab.png")
        cell.delegate = self
        return cell
    }
    
    
    
    //MARK: - Model Manipulation Methods
    func loadItems(with request: NSFetchRequest<Friends> = Friends.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }

}

//MARK: Search Extention
//searches the list of your friends...
//we have to add another query to search the Firebase database
extension FriendListScreen: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Friends> = Friends.fetchRequest()
        request.predicate = NSPredicate(format: "friendsEmail CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "friendsEmail", ascending: true)]
        
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



//MARK: SWipe CEll Kit

extension FriendListScreen: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let swipeAction = SwipeAction(style: .default, title: "Book Shelf") { action, indexPath in
            // handle action by updating model with deletion
            
            self.authInstance.otherUser = self.itemArray[indexPath.row].friendsEmail!
            self.performSegue(withIdentifier: "friendsBookShelf", sender: self)
//            self.context.delete(self.itemArray[indexPath.row])
//            self.itemArray.remove(at: indexPath.row)
//            CoreDataClass.sharedCoreData.saveContext()
        }
        
        // customize the action appearance
        swipeAction.image = UIImage(named: "book-icon")
        
        return [swipeAction]
    }
    
    
}
