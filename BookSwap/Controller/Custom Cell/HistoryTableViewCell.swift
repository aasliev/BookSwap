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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
