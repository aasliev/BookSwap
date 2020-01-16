//
//  HistoryTableViewCell.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/22/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sendersEmail: UILabel! //user who did swap request
    @IBOutlet weak var bookData: UILabel!
    @IBOutlet weak var reciversEmail: UILabel! //who recieves swap request
    //@IBOutlet weak var bookUser2: UILabel!
    @IBOutlet weak var inProcessLbl: UILabel!
    @IBOutlet weak var sendersProfilePicture: UIImageView!
    @IBOutlet weak var recieversProfilePicture: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //senders Profile Picture
        sendersProfilePicture.layer.cornerRadius = sendersProfilePicture.frame.size.width/2
        sendersProfilePicture.clipsToBounds = true
        sendersProfilePicture.layer.borderColor = UIColor.white.cgColor
        sendersProfilePicture.layer.borderWidth = 1
        
        //recievers profile picture
        recieversProfilePicture.layer.cornerRadius = recieversProfilePicture.frame.size.width/2
        recieversProfilePicture.clipsToBounds = true
        recieversProfilePicture.layer.borderColor = UIColor.white.cgColor
        recieversProfilePicture.layer.borderWidth = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
