//
//  NotificatonsScreen.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class NotificatonsScreen: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 100

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationCell
        cell.notificationTextLabel.text = "Asliddin Asliev would like to be friends with you."

        return cell
    }


}
