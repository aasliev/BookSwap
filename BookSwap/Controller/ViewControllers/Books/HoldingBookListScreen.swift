//
//  HoldingBookListScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import CoreData


class HoldingBookListScreen: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        // Do any additional setup after loading the view.
    }
    
    //MARK: Tableview methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return !authInstance.isItOtherUsersPage(userEmail: usersBookShelf!) ?  currentUserItems.count : otherUserItems.count
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "holdListCell", for: indexPath) as! HoldBookTableViewCell
        //initialize cell..
        
        
        
        return cell
    }
}
