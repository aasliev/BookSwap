//
//  fucntions.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 10/15/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Foundation
import UIKit

class UIalert{

    func createUIalert(_ message : String, _ screen : UIViewController )
    {
    let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alertController.addAction(action)
    screen.present(alertController, animated: true, completion: nil)
    
    }
    
}

