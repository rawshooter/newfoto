//
//  NotificationView.swift
//  mynews
//
//  Created by Thomas Alexnat on 02.04.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import Foundation
import UIKit

class NotificationView: UIVisualEffectView{
    
    /*
    UIVisualEffectView {
    
    internal init() {
    super.init(effect: UIBlurEffect(style: .light))
    commonInit()
    }
    
    */
    
    // checks to have small or large labels
    let sizeLength = 35
    
    let label = UILabel()
    
    let targetSize      =    CGRect(x: 1020, y: 780, width: 850, height: 260   )
    let targetSizeSmall =    CGRect(x: 20, y: 950, width: 650, height: 100   )
    

    private let hiddenPosition: CGRect      =    CGRect(x: 1920, y: 780, width: 850, height: 260   )
    private let hiddenPositionSmall: CGRect =    CGRect(x: -1000, y: 950, width: 650, height: 100   )
    
    private var message: String = ""
    
    
    internal init() {
        super.init(effect: UIBlurEffect(style: .dark))
        commonInit()
    }
    
    fileprivate func commonInit() {
      //  backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.4)
        
        //backgroundColor = UIColor(white: 0.8, alpha: 0.36)
        layer.cornerRadius = 16.0
        layer.masksToBounds = true
        label.numberOfLines = 0
        
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(self.label)
        contentView.bringSubview(toFront: label)
       setUpMyLabel()
        

        
        
    }
    
    
    func setUpMyLabel() {
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95),
            label.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.95)])
    }
    
    /*
    override init(frame: CGRect) {
        self.message = ""
        
        super.init(frame: frame)
        resetLayout()
        
        
    }
    */
    
    private func resetLayout(){
        DispatchQueue.main.async {
            
        
            self.layer.opacity = 0
            self.frame = self.hiddenPosition
            self.layer.removeAllAnimations()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /**
     Displays a message with the specified duration
     */
    func showError(message: String){
        resetLayout()
        

        let duration: TimeInterval = 2
        
        DispatchQueue.main.async {
            if(message.count > self.sizeLength ){
                self.frame =  self.hiddenPosition
            } else {
                self.frame =  self.hiddenPositionSmall
            }
            
            self.label.text = message
          //  self.backgroundColor = UIColor.red
            self.label.textColor = UIColor.white
            self.label.textAlignment = .center
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                
                if(message.count > self.sizeLength ){
                    self.frame =  self.targetSize
                } else {
                    self.frame =  self.targetSizeSmall
                }
                
                self.layer.opacity = 1
            }, completion: { (bool) in
                
                
                // an fade out
                UIView.animate(withDuration: 0.5, delay: duration, options: [], animations:{
                    if(message.count > self.sizeLength ){
                        self.frame =  self.hiddenPosition
                    } else {
                        self.frame =  self.hiddenPositionSmall
                    }
                    self.layer.opacity = 0
                }, completion: nil)
                
            })
        }
    }
    
    
    /**
     Displays a message without completion handler
     */
    func showMessage(message: String){
        showMessage(message: message, completion: nil)
    }
    
    
    /**
     Displays a message with the specified duration
     - parameter message: The message to be displayed
     - parameter duration: Time how long the messge is displayed
     - parameter completion: completion closure handler with no additional parameters
     that is called after the messge has been faded out after the
     duration period. since the closure is optional it is
     automatically an escaping method with the  `completion: (() -> Void)?` syntax
     
     */
    func showMessage(message: String, completion: (() -> Void)? ) {
        let duration: TimeInterval = 2
        resetLayout()
        

        DispatchQueue.main.async {
            if(message.count > self.sizeLength ){
                self.frame =  self.hiddenPosition
            } else {
                self.frame =  self.hiddenPositionSmall
            }
            
            self.label.text = message
      //      self.backgroundColor = UIColor.lightGray
          //  self.label.textColor = UIColor.black
            self.label.textAlignment = .center
            self.label.textColor = UIColor.white
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                if(message.count > self.sizeLength ){
                    self.frame =  self.targetSize
                } else {
                    self.frame =  self.targetSizeSmall
                }
                self.layer.opacity = 1
            }, completion: { (bool) in
                
                
                // an fade out
                UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseInOut, animations:{
                    if(message.count > self.sizeLength ){
                        self.frame =  self.hiddenPosition
                    } else {
                        self.frame =  self.hiddenPositionSmall
                    }
                    self.layer.opacity = 0
                }, completion: nil)
                
                
                // callback the the message has disappeared
                // optional if provided
                if let completionHandler = completion{
                    completionHandler()
                }
                
            })
        }
    }
    
}


