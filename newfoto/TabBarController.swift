//
//  TabBarController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 21.01.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attributes: [NSAttributedStringKey : Any] =
            [
                .font: UIFont.systemFont(ofSize: 40, weight: .bold)
        ]
        
       
        if let tabs = tabBar.items as? [UITabBarItem]{
            for tab in tabs{
                tab.setTitleTextAttributes(attributes, for: .normal)
                tab.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 40, weight: .bold)], for: .selected)
                
            }
        }

        
    
    }
}
