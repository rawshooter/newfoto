//
//  HeaderView.swift
//  newfoto
//
//  Created by Thomas Alexnat on 09.04.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    // label for date and information display
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    
    // backtrack to get the controller to call the map
    // function
    var controller: SmartCollectionController?
    
    
    @IBAction func mapButtonAction(_ sender: Any) {
        controller?.showMapController()
    }
    
    
    
    @IBOutlet weak var infoStack: UIStackView!
    
    
    var lastCellFocus: [UIFocusEnvironment] = []
    
    // the focus guide to enable access
    // to the header buttons
    var focusGuide: UIFocusGuide?

    // was the button the last element
    // then ignore
    /*
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        
        print("previous \(context.previouslyFocusedView)")
        print("next \(context.nextFocusedView)")
        
        // do we have a previous focused view?
        if let previousView = context.previouslyFocusedView{
            // restore the focused view before the map button was
            // selected
            
            if(previousView is UICollectionViewCell){
                print("Cell found")
                focusGuide?.preferredFocusEnvironments = [mapButton]
                lastCellFocus = [previousView]
            }
            
            
            
            if(previousView == mapButton){
                //focusGuide?.preferredFocusEnvironments = lastCellFocus
                                focusGuide?.preferredFocusEnvironments = []
                
                print("Coming from map button and jump to saved state")
                return
            }
            
            /*
            // no button was focused so we guess it
            // was something like a cell view
            if(previousView != focusGuide){
                print("coming not from mapbutton and not focusguide")
            //    lastCellFocus = [previousView]
            }
           */
        }
        
        
        
        /*
      
        // do we have a previous focused view?
        if let nextView = context.nextFocusedView{
            if(nextView == focusGuide){
                print("focusguide hit")
                if(context.previouslyFocusedView != mapButton){
                    focusGuide?.preferredFocusEnvironments = [mapButton]
                }
            }
        }
        
        print("no map button")
        focusGuide?.preferredFocusEnvironments = [mapButton]
        */
        
    }
    */
}
