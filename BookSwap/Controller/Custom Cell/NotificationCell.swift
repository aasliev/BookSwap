//
//  NotificationCell.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate: class {
    func notificationButtonPressed(ifAccepted : Bool, indexRow : Int)
}

class NotificationCell: UITableViewCell {
    
    weak var delegate: NotificationCellDelegate?

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
    
    
    func hideButtons () {
        acceptButton.isHidden = true
        declineButton.isHidden = true
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        //hideButtons()
        delegate?.notificationButtonPressed(ifAccepted: true,  indexRow : (sender as! UIButton).tag)
        
    }
    
    @IBAction func declineButtonPressd(_ sender: Any) {
        //hideButtons()
        
        delegate?.notificationButtonPressed(ifAccepted: false, indexRow : (sender as! UIButton).tag)
        
        
    }
    
    
}
