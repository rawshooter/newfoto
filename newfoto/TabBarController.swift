//
//  TabBarController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 21.01.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    // will be true when the focus in the
    // first subcontroller was loaded (the focus environment)
    

    var isAlbumLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes: [NSAttributedStringKey : Any] =
            [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold)
        ]
        
       
        if let tabs = tabBar.items {
            for tab in tabs{
                tab.setTitleTextAttributes(attributes, for: .normal)
                tab.setTitleTextAttributes(attributes, for: .selected)
                
                
                //tab.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 40, weight: .bold)], for: .selected)
                
            }
        }
    }
    
    
    func focusOnceAlbumController(){
        isAlbumLoaded = true
         view.updateFocusIfNeeded()
        
    }
    
    // just display the initial first tab
    // without the menu
    // and then display the menu
    override var preferredFocusEnvironments: [UIFocusEnvironment]{
        print("checking focus")
        
        if(isAlbumLoaded){
            isAlbumLoaded = false
            return self.selectedViewController!.preferredFocusEnvironments
        
        } else {
            return self.tabBar.preferredFocusEnvironments
        }
        
        
    }
}
