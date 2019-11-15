//
//  FirebaseAuth.swift
//  BookSwap
//
//  Created by RV on 11/15/19.
//  Copyright © 2019 RV. All rights reserved.
//


import Firebase

class FirebaseAuth {
    
    func getCurrentUserEmail() -> String {
        
        return (Auth.auth().currentUser?.email)!
        
    }
}
