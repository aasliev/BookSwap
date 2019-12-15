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
    
    let databaseIstance = FirebaseDatabase.shared
    
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
        
        swap.isHidden = true
        
        //databaseIstance.addHoldingBook(bookOwnerEmail: <#T##String#>, bookName: <#T##String#>, bookAuthor: <#T##String#>)
        
    }
}
