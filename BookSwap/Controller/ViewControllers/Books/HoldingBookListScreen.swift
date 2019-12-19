//
//  HoldingBookListScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class HoldingBookListScreen: UITableViewController {
    
    //arrays
    var currentUserItems = [HoldBook]()
    var otherUserItems = [OtherHoldBook]()

    
    //fetch request
    var requestForHoldBooks : NSFetchRequest<HoldBook> = HoldBook.fetchRequest()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        loadItems()
    }
    
    //MARK: Tableview methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!) ?  currentUserItems.count : otherUserItems.count
        return currentUserItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "holdListCell", for: indexPath) as! HoldBookTableViewCell
        //initialize cell..
        cell.authorOfTheBook.text = currentUserItems[indexPath.row].author
        cell.nameOfTheBook.text = currentUserItems[indexPath.row].bookName
        cell.bookOwner.text = currentUserItems[indexPath.row].bookOwner
        return cell
    }
    
    
    //MARK: Model Manipulation Methods
    
    func loadItems() {
        do {
            currentUserItems = try CoreDataClass.sharedCoreData.getContext().fetch(requestForHoldBooks)
        } catch {
            print("error fetching data \(error)")
        }
    }
}
