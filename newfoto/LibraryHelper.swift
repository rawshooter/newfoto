//
//  LibraryHelper.swift
//  newfoto
//
//  Created by Thomas Alexnat on 11.02.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

class LibraryHelper: NSObject {
    /*
    override init() {
        
        
    }
    // 
    */
    
    func checkStatus() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
    
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            return true
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            return false
        }
            
          /*
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            // ask the user
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                }
                    
                else {
                    
                }
            })
            
        }
*/
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
            return false
        }

        return false
    }
    /*
    
    func requestAccess(){
        let status = PHPhotoLibrary.authorizationStatus()
        // ask again
        if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            // ask again the user
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                }
                    
                else {
                    
                }
            })
        }
    }
*/
}
