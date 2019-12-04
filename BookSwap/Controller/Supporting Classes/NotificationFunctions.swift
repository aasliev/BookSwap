//
//  NotificationFunctions.swift
//  BookSwap
//
//  Created by Asliddin Asliev on 12/3/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Notifiactions {
    //singleton
    let databaseInstance = FirebaseDatabase.shared
    let authInstance = FirebaseAuth.sharedFirebaseAuth
    
    private init(){}
    
    func sendRequest(sender : String, reciever: String, code: Int){
        //if code == 0 (friend request)
        //inside the resivers notification entity in fireStore add senders name(username or email)
        //with the code 0
    }
}
