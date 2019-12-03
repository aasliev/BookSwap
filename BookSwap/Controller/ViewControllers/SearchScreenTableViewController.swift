//
//  SearchScreenTableViewController.swift
//  BookSwap
//
//  Created by RV on 12/1/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class SearchScreenTableViewController: UITableViewController {

    
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    let USER_NAME = "UserName"
    let RATING = "Rating"
    let EMAIL = "Email"
    
    
    
    var searchResult : Dictionary<Int, Dictionary<String, Any>>  = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //loadResult(search: "Mr. One")
        
        tableView.rowHeight = 80
        
    }
    
    
    //MARK: Search User
    func loadResult(search: String){
        
        searchResult.removeAll()
        databaseIstance.getListOfSearchFriends(usersEmail: authInstance.getCurrentUserEmail()!, searchText: search) { (dict) in
            
            var index = 0
            
            for (_, data) in dict {
                
                self.searchResult[index] = data
                
                index += 1
            }
            
            print("This is Dict: \(self.searchResult as AnyObject)")
            
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return searchResult.count
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        authInstance.otherUser = (searchResult[indexPath.row]![EMAIL] as! String)
        
        performSegue(withIdentifier: "toProfileScreen", sender: self)
        
        //to create click animation
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriendCell", for: indexPath) as! SearchScreenTableViewCell
        
        cell.userNameLbl?.text = (searchResult[indexPath.row]![USER_NAME]! as! String)
        cell.ratingLbl?.text = ("\(searchResult[indexPath.row]![RATING]!)")
        cell.emailLbl?.text = (searchResult[indexPath.row]![EMAIL]! as! String)
        
        return cell
    }

    
}


extension SearchScreenTableViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       //here goes your code
        self.loadResult(search: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count==0{
            //loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            //loadItems()
            //tableView.reloadData()
        }
    }
    
}
