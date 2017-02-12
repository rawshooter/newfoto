//
//  DisclaimerViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 11.02.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

class DisclaimerViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // if access to the library is not
        // determined yet and not accessed or denied
        // show the get access button
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.notDetermined) {
            actionButton.isHidden = false
        } else {

                actionButton.isHidden = true

        }
        

        // Do any additional setup after loading the view.//
        print("Disclaimer View Controller was loaded")
    }


    @IBAction func requestLibraryAction(_ sender: Any) {
        print("requesting photo library action")
        let status = PHPhotoLibrary.authorizationStatus()
        // ask again
        print("Status: \(status) " )
   
        if (status == PHAuthorizationStatus.authorized) {
            print("Access has been granted.")
           
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
            print("Access has been denied.")
        }
    
        else if (status == PHAuthorizationStatus.restricted) {
            // Access has been denied.
            print("restricted.")
        }
        
        
        
        PHPhotoLibrary.requestAuthorization({ (newStatus) in
            
            if (newStatus == PHAuthorizationStatus.authorized) {
                print("Authorized")
                self.dismiss(animated: false, completion: nil)
            }
                
            else {
                print("Nothing Authorized")
                self.dismiss(animated: false, completion: nil)
                
            }
        })
   
        
        
        
        
        if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            // ask again the user
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                                    print("Authorized")
                        self.dismiss(animated: false, completion: nil)
                }
                    
                else {
                    print("Nothing Authorized")
                     self.dismiss(animated: false, completion: nil)
                    
                }
            })
        }

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
