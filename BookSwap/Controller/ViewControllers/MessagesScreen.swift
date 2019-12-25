//
//  MessagesScreenTableViewController.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
let progressBarInstance = SVProgressHUDClass.shared

class MessagesScreen: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        
        progressBarInstance.displayMessage(message: "Messages will be in the next version.")

    }

}
