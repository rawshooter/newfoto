//
//  OverviewCell.swift
//  newfoto
//
//  Created by Thomas Alexnat on 12.11.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit


class OverviewCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!{
        willSet(image) {
            print("image setter called \(image)")
        }
    }


    @IBOutlet weak var label: UILabel!

    
    // The cells zoom when focused.
    var focusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.2, y: 1.2)
    }
    
    // The cells zoom when focused.
    var unFocusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    
    
    
    func setFocused(focused: Bool,
                    withAnimationCoordinator coordinator: UIFocusAnimationCoordinator){

        if focused {
            self.contentView.addGestureRecognizer(panGesture)
            
            // bringt to front
            superview?.bringSubview(toFront: self)
            
            // zoom and bring shadow in
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.transform = self.focusedTransform
                self.layer.masksToBounds = false;
                self.layer.shadowOffset = CGSize(width:15, height:15);
                self.layer.shadowRadius = 5;
                self.layer.shadowOpacity = 0.2;
                
                // any other focus-based UI state updating
            }, completion: nil)
            
        }
        else {
            
            self.contentView.removeGestureRecognizer(panGesture)
            
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.transform = self.unFocusedTransform
                self.layer.shadowOpacity = 0;
                self.layer.masksToBounds = false;
                self.layer.shadowOffset = CGSize(width:15, height:15);
                self.layer.shadowRadius = 5;

                
                // any other focus-based UI state updating
            }, completion: nil)
        }
    }


    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self,
                                         action: #selector(viewPanned(pan:))
        )
        pan.cancelsTouchesInView = false
        return pan
    }()
    

    
    
    
    var initialPanPosition: CGPoint?
    
    func viewPanned(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            print("pan begin")
            initialPanPosition = pan.location(in: contentView)
            
        case .changed:
            //print("pan changed")
            
            if let initialPanPosition = initialPanPosition {
                let currentPosition = pan.location(in: contentView)
                let diff = CGPoint(
                    x: currentPosition.x - initialPanPosition.x,
                    y: currentPosition.y - initialPanPosition.y
                )
                
                
                
                 let parallaxCoefficientX = 1 / self.contentView.frame.width * 16
                 let parallaxCoefficientY = 1 / self.contentView.frame.height * 16
                 
                 // Transform is the default focused transform, translated.
                 transform = focusedTransform.concatenating(
                 CGAffineTransform(translationX: diff.x * parallaxCoefficientX,
                                        y: diff.y * parallaxCoefficientY
                    )
                 )

            }
        case .ended:
            print("pan gesture ended")
            
            if(isFocused){
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .beginFromCurrentState,
                               animations: { () -> Void in
                                self.transform = self.focusedTransform
                                //                     nameLabel.transform = CGAffineTransformIdentity
                },
                               completion: nil)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .beginFromCurrentState,
                               animations: { () -> Void in
                                self.transform = self.unFocusedTransform
                                //                     nameLabel.transform = CGAffineTransformIdentity
                },
                               completion: nil)
            }

            

        default:
            print("default pan gesture")
            // .Canceled, .Failed, etc.. return the view to it's default state. with the focus transformation style
            UIView.animate(withDuration: 1.0,
                                       delay: 0,
                                       usingSpringWithDamping: 0.8,
                                       initialSpringVelocity: 0,
                                       options: .beginFromCurrentState,
                                       animations: { () -> Void in
                                        self.transform = self.unFocusedTransform
                   //                     nameLabel.transform = CGAffineTransformIdentity
            },
                                       completion: nil)
            

        }
    }
    
    
    
    

    

    
    
}
