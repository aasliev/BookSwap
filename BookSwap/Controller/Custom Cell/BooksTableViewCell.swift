//
//  BooksTableViewCell.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 11/18/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit
import SwipeCellKit

class BooksTableViewCell: SwipeTableViewCell {

    
    @IBOutlet weak var nameOfTheBook: UILabel!
    @IBOutlet weak var authorOfTheBook: UILabel!
    @IBOutlet weak var swap: UIButton!
    
    @IBOutlet weak var holderLabel: UILabel!
    let databaseIstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameOfTheBook.lineBreakMode = .byWordWrapping // or NSLineBreakMode.ByWordWrapping
        textLabel!.numberOfLines = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func swapButton(_ sender: Any) {
        
        
        //Checking the number of holding Books. if true, holding book is less than limit
        if databaseIstance.canUserHoldMoreBook() {
            
            swap.isHidden = true
            swap.setTitle("Requested", for: .normal)
            let currentUserEmail = authInstance.getCurrentUserEmail()
            
            databaseIstance.getUserName(usersEmail: currentUserEmail) { (userName) in
                
                self.databaseIstance.addSwapReqestNotification(senderEmail: currentUserEmail, sendersUserName: userName, receiversEmail: self.authInstance.usersScreen, bookName: self.nameOfTheBook.text!, bookAuthor: self.authorOfTheBook.text!)
            }
        } else {
            SVProgressHUDClass.shared.displayError(errorMsg: "You are holding \(databaseIstance.numberOfHoldingBooks) books. \nWhich maximum number of book allowed.")
        }
        
        
        //databaseIstance.addHoldingBook(bookOwnerEmail: authInstance.usersScreen, bookName: nameOfTheBook.text!, bookAuthor: authorOfTheBook.text!)
        
    }
}
