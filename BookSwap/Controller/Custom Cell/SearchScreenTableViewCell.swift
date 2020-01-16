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
    @IBOutlet weak var profilePicture: UIImageView!
    
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
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
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add Button Pressed!! Inside Search Screen")
        print("UserName: \(ratingLbl.text!)")
        
        let progressBarInstance = SVProgressHUDClass.shared
        progressBarInstance.displayProgressBar()
        
        let currentUserEmail = authInstance.getCurrentUserEmail()
        //FirebaseDatabase.shared.addNewFriend(currentUserEmail: currentUserEmail , friendsEmail: emailLbl.text!, friendsUserName: userNameLbl.text!)
        
        self.databaseIstance.addFriendReqestNotification(senderEmail: currentUserEmail, sendersUserName: authInstance.getCurrentUserName(), receiversEmail: self.emailLbl.text!)
        
        self.addButton.setTitle("Sent", for: .normal)
        self.addButton.isEnabled = false
        progressBarInstance.dismissProgressBar()
        progressBarInstance.displaySuccessSatus(successStatus: "Request has been sent to \(String(describing: self.userNameLbl.text!))")
//        databaseIstance.getUserName(usersEmail: currentUserEmail) { (userName) in
//
//            self.databaseIstance.addFriendReqestNotification(senderEmail: currentUserEmail, sendersUserName: userName, receiversEmail: self.emailLbl.text!)
//
//
//        }
        
    }
    
}
