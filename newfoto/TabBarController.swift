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
    let font = UIFont.systemFont(ofSize: 29, weight: .bold)
    let tabFont = UIFont.systemFont(ofSize: 40, weight: .bold)
    var label = UILabel(frame: CGRect(x: 1795, y: 42, width: 150, height: 60))
    
    
    func getLabelColor() -> UIColor {
        let defaultLabelColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
        
        guard(self.traitCollection.responds(to: #selector(getter: UITraitCollection.userInterfaceStyle)))
            else { return  defaultLabelColor }
        
        let style = self.traitCollection.userInterfaceStyle
        
        switch style {
        case .light:
            return defaultLabelColor
        case .dark:
            return UIColor(red: 1, green: 1, blue: 1, alpha: 0.85)
            
        case .unspecified:
            return defaultLabelColor
        }
    }
    
    
    @objc func updateClock() -> Void {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
        let time = dateFormatter.string(from: date)
        
        
        label.text =  time
    }
    
    

    var isAlbumLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupUI()
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateClock), userInfo: nil, repeats:true);
        
        
        
    }
    
    
    
    
    func setupUI(){
        
        
        
        
        label.font = font
        label.textColor = getLabelColor()
        
        
        //  label.attributedText(attributes, for: .normal)
        
        
        tabBar.addSubview(label)
        label.numberOfLines = 0
        tabBar.bringSubview(toFront: label)
        
        
        
        // style the tabs
        // provide a better accessibility styling for the tabbar
        let attributes: [NSAttributedStringKey : Any] =
            [
                .font: tabFont
        ]
        
        if let tabs = tabBar.items {
            for tab in tabs{
                tab.setTitleTextAttributes(attributes, for: .normal)
                tab.setTitleTextAttributes(attributes, for: .selected)
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
