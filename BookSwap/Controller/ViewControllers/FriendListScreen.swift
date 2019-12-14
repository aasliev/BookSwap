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

    //Array which takes objects of Friends
    var itemArray = [Friends]()
    var otherFriendsList = [OthersFriend]()
    
    //context of Core Data file
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Instances of other classes, which will be used to access the methods
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    let coreDataClassInstance = CoreDataClass.sharedCoreData
    
    //Variables to keep track of who's screen is user on
    var usersFriendsList : String?
    var friensEmail : String?
    
    //Request for search result
    let requestForFriends: NSFetchRequest<Friends> = Friends.fetchRequest()
    let reqestForOthersFriends : NSFetchRequest<OthersFriend> = OthersFriend.fetchRequest()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        tableView.rowHeight = 80
        self.hideKeyboardWhenTappedAround()

    }
    
    override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        
        loadItems()
        
    }
    
    //MARK: TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //checks if it is not logged in user's friendsList, if true
        //it returns count of otherFriendsList elements. If false, itemArray's count
        return !authInstance.isItOtherUsersPage(userEmail: usersFriendsList!) ?  itemArray.count : otherFriendsList.count
        
    }
    //This method will be called when user selects or clicks on any row inside table
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //to create click animation
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("indexPath.row: \(indexPath.row)")
        
        if authInstance.isItOtherUsersPage(userEmail: usersFriendsList!){
            
            friensEmail = otherFriendsList[indexPath.row].friendsEmail!
        } else {
            //setting friendsEmail equals to email of
            friensEmail = itemArray[indexPath.row].friendsEmail!
        }
        performSegue(withIdentifier: "friendsProfileView", sender: self)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsTableViewCell
        
        if !authInstance.isItOtherUsersPage(userEmail: usersFriendsList!) {
            
            cell.userName?.text = itemArray[indexPath.row].userName
            cell.add.isHidden = true
            
        } else {
            cell.userName?.text = otherFriendsList[indexPath.row].userName
            cell.add.isHidden = true
        }
        
        //cell.detailTextLabel = itemArray[indexPath.row].numOfSwaps
        //cell.imageView!.image = UIImage(named: "bookcrab.png")
        cell.delegate = self
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "friendsProfileView" {
            
            let destinationVC = segue.destination as! ProfileScreen
            destinationVC.usersProfile = friensEmail
            
        } else if segue.identifier == "friendsBookShelf" {
            
            let destinationVC = segue.destination as! booksPageViewController
            destinationVC.usersBookPage = friensEmail
        }
        
    
    }
    
    
    //MARK: - Model Manipulation Methods
    func loadItems(with request: NSFetchRequest<Friends> = Friends.fetchRequest()) {
        do {
            //checks which user is currently on the WishList page
            //NOTE: Other User will be true if user open someone else's WishList
            if !authInstance.isItOtherUsersPage(userEmail: usersFriendsList!) {
                
                itemArray = try context.fetch(requestForFriends)
            } else {
                
                if (otherFriendsList.count == 0) {
                    databaseIstance.getListOfFriends (usersEmail: usersFriendsList!) { (dataDictionary) in
                        self.loadDataForOtherUser(dict: dataDictionary)
                    }
                } else {
                    otherFriendsList = try context.fetch(reqestForOthersFriends)
                }
            }
            tableView.reloadData()
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    //Loads the data inside OthersWishList array, which is received from Firestore
    func loadDataForOtherUser(dict : Dictionary<Int  , Dictionary<String  , Any>>) {
        
        //Clearing the data stored inside Core Data file\
        
        self.coreDataClassInstance.resetOneEntitie(entityName: "OthersFriend")
        
        //Clearing the array which holds objects of 'OthersOwnedBook'
        otherFriendsList.removeAll()
        
        for (_, data) in dict {
            
            //creating an object of OthersWishList with the context of Core Data
            let newFriend = OthersFriend(context: self.context)
            
            //adding data from dictionary, data holds information such as bookName and author
            newFriend.friendsEmail = (data[self.databaseIstance.FRIENDSEMAIL_FIELD] as! String)
            newFriend.userName = (data[self.databaseIstance.USER_EMAIL_FIELD] as! String)
            
            //Appending inside otherUser array
            otherFriendsList.append(newFriend)
        }
        
        //saving all the changes made in core data
        coreDataClassInstance.saveContext()
        
        //reloading the table view to show the latest result
        tableView.reloadData()
        
    }

}


//MARK: Search Extention
//searches the list of your friends...
//we have to add another query to search the Firebase database
extension FriendListScreen: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //creating NSPredicate which finds keyword in bookName and author field
        let nsPredicate = NSPredicate(format: "(bookName CONTAINS[cd] %@) OR (author CONTAINS[cd] %@)", searchBar.text!, searchBar.text!)
        
        //once the result is recived, sorting it by bookName
        let nsSortDescriptor = [NSSortDescriptor(key: "bookName", ascending: true)]
        
        //Checking if otherUser is empty
        if (!authInstance.isItOtherUsersPage(userEmail: usersFriendsList!)) {
            
            //creating request for current user's own WishList page
            requestForFriends.predicate = nsPredicate
            requestForFriends.sortDescriptors = nsSortDescriptor
            
        } else {
            
            //creating reqest for other user's WishList page
            reqestForOthersFriends.predicate = nsPredicate
            reqestForOthersFriends.sortDescriptors = nsSortDescriptor
        }
        
        loadItems()
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
            
            self.friensEmail = self.itemArray[indexPath.row].friendsEmail!
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
