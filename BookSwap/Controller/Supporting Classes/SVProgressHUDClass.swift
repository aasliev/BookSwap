//
//  SVProgressHUDClass.swift
//  BookSwap
//
//  Created by RV on 12/20/19.
//  Copyright © 2019 RV. All rights reserved.
//

import Foundation
import SVProgressHUD

class SVProgressHUDClass {
    
    //Singleton
    static let shared = SVProgressHUDClass()
    
    private init() {
    }
    
    
    //MARK: Display Methods
    func displayProgressBar () {
        
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setDefaultAnimationType(SVProgressHUDAnimationType.native) 
        SVProgressHUD.setForegroundColor(UIColor.init(white: 100, alpha: 1))           //Ring Color
        SVProgressHUD.setBackgroundColor(UIColor.init(white: 0, alpha: 0.0))        //HUD Color
        SVProgressHUD.setBackgroundLayerColor(UIColor.init(white:0, alpha: 0.6))    //Background Color
        SVProgressHUD.show()
    }
    
    
    func displaySuccessSatus (successStatus: String) {
        SVProgressHUD.showSuccess(withStatus: successStatus)
    }
    
    func displayMessage (message : String) {
        SVProgressHUD.showInfo(withStatus: message)
    }
    
    func displayError (errorMsg: String) {
        SVProgressHUD.showError(withStatus: errorMsg)
    }
    
    
    func dismissProgressBar () {
        SVProgressHUD.dismiss()
    }

}
