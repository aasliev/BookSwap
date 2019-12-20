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
    
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
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
        
        let currentUserEmail = authInstance.getCurrentUserEmail()
        //FirebaseDatabase.shared.addNewFriend(currentUserEmail: currentUserEmail , friendsEmail: emailLbl.text!, friendsUserName: userNameLbl.text!)
        
        databaseIstance.getUserName(usersEmail: currentUserEmail) { (userName) in
            
            self.databaseIstance.addFriendReqestNotification(senderEmail: currentUserEmail, sendersUserName: userName, receiversEmail: self.emailLbl.text!)
        }
        addButton.setTitle("Request\nSent", for: .highlighted)
    }
    
}
