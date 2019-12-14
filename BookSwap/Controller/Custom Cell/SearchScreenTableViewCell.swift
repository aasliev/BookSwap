//
//  SearchScreenTableViewCell.swift
//  BookSwap
//
//  Created by RV on 12/1/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import SwipeCellKit

class SearchScreenTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add Button Pressed!! Inside Search Screen")
        print("UserName: \(ratingLbl.text!)")
        
        let currentUserEmail = FirebaseAuth.sharedFirebaseAuth.getCurrentUserEmail()!
        FirebaseDatabase.shared.addNewFriend(currentUserEmail: currentUserEmail , friendsEmail: emailLbl.text!, friendsUserName: userNameLbl.text!)
        
        CoreDataClass.sharedCoreData.addFriendIntoCoreData(friendsEmail: emailLbl.text!, friendsUserName: userNameLbl.text!, numberOfSwaps: "00")
        
        addButton.isHidden = true
    }
    
}
