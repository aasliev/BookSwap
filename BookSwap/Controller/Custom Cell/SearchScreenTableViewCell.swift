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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
    }
    
}
