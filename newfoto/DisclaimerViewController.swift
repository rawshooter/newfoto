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

    @IBOutlet weak var disclaimerLabel: UITextView!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    // avoid a race condition
    // when the view reappears from
    // acceptance of photo libaray
    static var animationsRunning = false
    
    
    // The cells zoom when focused.
    var focusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
    
    // The cells zoom when focused.
    var unFocusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func actionUHD(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "UHDViewController") as? UHDViewController{
            self.show(controller, sender: self)
        }
        
    }
    
    
    @IBAction func actionHD(_ sender: UIButton) {
    
        if let controller = storyboard?.instantiateViewController(withIdentifier: "HDViewController") as? HDViewController{
            self.show(controller, sender: self)
        }
    }
    
    
    
    @IBAction func actionAbout(_ sender: UIButton) {
        
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AboutController") as? AboutViewController{
            print("Controller found")
            
            
            
            // controller.presentingSmartController = self
            self.show(controller, sender: self)
            
            //self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func actionLicense(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "LicenseController") as? LicenseViewController{
            print("Controller found")
            
            
            
            // controller.presentingSmartController = self
            self.show(controller, sender: self)
            
            //self.present(controller, animated: true, completion: nil)
            
        }
        
    }
    
    func zoomIn(){
        UIView.animate(withDuration: 40,
                       delay: 1,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations: { () -> Void in self.imageView.transform = self.focusedTransform}
        ,
                       completion: { (completed: Bool) -> Void in
                        
                        
                        // boolean check if really the animation was completed
                        if(completed){
                            self.zoomOut()
                        }
                        
                        
        }
        )
    }
    
    func zoomOut(){
        
        
        UIView.animate(withDuration: 40,
                       delay: 1,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations: { () -> Void in self.imageView.transform = self.unFocusedTransform}
            ,
                       completion: { (completed: Bool) -> Void in
                        
                        // boolean check if really the animation was completed
                        if(completed){
                            self.zoomIn()
                        }
                        
                        
        }
        )
        
        
    }
    
    
    // check when the controller is shown if we have access to the photo library
    override func viewDidAppear(_ animated: Bool) {
        
               view.layer.removeAllAnimations()
        
        // start animations only if they are NOT running
        // to avoid flickering
        //if(!DisclaimerViewController.animationsRunning){
            DisclaimerViewController.animationsRunning = true
            zoomIn()
       // }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // if access to the library is not
        // determined yet and not accessed or denied
        // show the get access button
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.notDetermined) {
            actionButton.isHidden = false
            disclaimerLabel.isHidden = true
        } else {

            actionButton.isHidden = true
            disclaimerLabel.isHidden = false
        }
        

        // Do any additional setup after loading the view.//
        print("Disclaimer View Controller was loaded")
    }


    func showMainTabController(){
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController{
            
            // show it on the highest level as a modal view
            // present(controller, animated: false, completion: nil)
            
            // show it on the highest level as a modal view
            //show(controller, sender: self)
            
            DispatchQueue.main.async {
                print("Showing off MainTabController")
                self.view.window?.rootViewController = controller
            }
        }
        
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
                //self.dismiss(animated: false, completion: nil)
                self.showMainTabController()
    
            }
                
            else {
                print("Nothing Authorized")
                // self.dismiss(animated: false, completion: nil)
                self.showMainTabController()
            }
        })

        
        
        
        if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            // ask again the user
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    print("Authorized")
                    self.showMainTabController()
                }
                    
                else {
                    print("Nothing Authorized")
                    self.showMainTabController()
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
