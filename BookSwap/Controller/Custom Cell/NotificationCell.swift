//
//  NotificationCell.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notificationTextLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        notificationTextLabel.text = "Asliddin Asliev would like to be friends with you"
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

}
