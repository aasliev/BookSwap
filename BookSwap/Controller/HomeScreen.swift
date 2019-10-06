//
//  HomeScreen.swift
//  BookSwap
//
//  Created by RV on 10/5/19.
//  Copyright © 2019 RV. All rights reserved.
//

import UIKit

class HomeScreen: UIViewController {

    @IBOutlet weak var userNameLbl: UITextField!
    @IBOutlet weak var pswdLbl: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func logInBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "toProfileScreen",  sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileScreen"{
            
            let destinationScreen = segue.destination as! ProfileScreen
            
            destinationScreen.userNameReciver = userNameLbl.text!
            
        }
    }
    
    @IBAction func unwindToHomeScreen(_ sender: UIStoryboardSegue){}
    
}
