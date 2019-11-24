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


class FriendListScreen: UITableViewController {

    var itemArray = [Friends]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadItems()

    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\n array count: ", itemArray.count)
        return itemArray.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        cell.userName?.text = itemArray[indexPath.row].friendsEmail
        cell.add.isHidden = true
        //cell.detailTextLabel = itemArray[indexPath.row].numOfSwaps
        //cell.imageView!.image = UIImage(named: "bookcrab.png")
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
    
    func saveItems()
    {
        do {
            try context.save()
            print("saved")
        } catch {
            print("Error saving context \(error)")
        }
        self.tableView.reloadData()
        
    }

}

//MARK: Search Extention
//searches the list of your friends...
//we have to add another query to search the Firebase database
extension FriendListScreen: UISearchBarDelegate
{
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
