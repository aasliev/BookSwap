//
//  FriendsTableViewCell.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 11/18/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import SwipeCellKit

class FriendsTableViewCell: SwipeTableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var add: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.borderWidth = 1
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func addButton(_ sender: Any) {
        
        
    }
}
