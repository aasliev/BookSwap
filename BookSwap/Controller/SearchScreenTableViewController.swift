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
    
    
    
    var searchResult : Dictionary<Int, Dictionary<String, Any>>  = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadResult(search: "Mr. One")
        
        tableView.rowHeight = 80
        
    }
    
    
    //MARK: Search User
    func loadResult(search: String){
        
        databaseIstance.getListOfSearchFriends(usersEmail: authInstance.getCurrentUserEmail()!, searchText: search) { (dict) in
            
            var index = 0
            
            for (_, data) in dict {
                
                self.searchResult[index] = data
                
                index += 1
            }
            
            print(self.searchResult as! AnyObject)
            
            self.tableView.reloadData()
        }
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return searchResult.count
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchFriendCell", for: indexPath) as! SearchScreenTableViewCell
        
        cell.userNameLbl?.text = (searchResult[indexPath.row]![USER_NAME]! as! String)
        cell.ratingLbl.text = ("\(searchResult[indexPath.row]![RATING]!)" as! String)
        print("This is cell: \(cell)")
        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
