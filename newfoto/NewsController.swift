//
//  DisclaimerViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 11.02.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

class NewsController: UIViewController {
    
    static let version = "1.22"
    static let versionKey = "VERSION"
    

    @IBAction func continueAction(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(NewsController.version, forKey: NewsController.versionKey)
        
            showMainTabController()
    }
    
    
    // check when the controller is shown if we have access to the photo library
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
}
