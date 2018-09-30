//
//  focusMapView.swift
//  newfoto
//
//  Created by Thomas Alexnat on 30.09.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit
import MapKit

/**
 This class enabled to unfocus specific menu button handling to
 focus other targets when pressing the menu button
 
 */
class focusMapView: MKMapView {

    fileprivate var isInRefocus = false
    
    fileprivate var refocusEnvironments: [UIFocusEnvironment] = []
    
    
    /**
     refocuses a view
    */
    func refocus(focusEnvironments: [UIFocusEnvironment]){
        isInRefocus = true
        refocusEnvironments = focusEnvironments
        
        self.setNeedsFocusUpdate()
        self.updateFocusIfNeeded()
        
        // back to normal
        isInRefocus = false
        refocusEnvironments = [self]
        
    }

    
    
    
    // by default focus the view by itsef
    override var preferredFocusEnvironments: [UIFocusEnvironment]{
        
        
        if(isInRefocus){
            return refocusEnvironments
        }
        
        return super.preferredFocusEnvironments
        
    }
    
    
    
}
