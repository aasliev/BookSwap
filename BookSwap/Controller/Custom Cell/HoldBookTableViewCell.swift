//
//  HoldBookTableViewCell.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/17/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class HoldBookTableViewCell: UITableViewCell {

    @IBOutlet weak var nameOfTheBook: UILabel!
    @IBOutlet weak var authorOfTheBook: UILabel!
    @IBOutlet weak var bookOwner: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func returnButtonPressed(_ sender: Any) {
        
        databaseInstance.addReturnBookRequestNotification(reciversEmail: bookOwner.text!, sendersEmail: authInstance.getCurrentUserEmail(), bookName: nameOfTheBook.text!, bookAuthor: authorOfTheBook.text!)
    }
    
}
