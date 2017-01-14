//
//  DetailControllerViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 16.11.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import MapKit
import Photos

class DetailController: UIViewController, UIGestureRecognizerDelegate {

    // defines the different states for the preview image
    // that slides in from left or right
    enum previewStates {
        case none
        case initializedLeft
        case initiailzedRight
        case snapToCenter
    }
    
    // to obtain the current mode of the preview image
    // for handling the gestures
    var previewMode: previewStates = previewStates.none
    
    
    // current asset list to be iterated through
    var phAssetResult: PHFetchResult<PHAsset>!
    
    // current pointer in photo list
    @IBOutlet weak var infoTextView: UITextView!
    var indexPosition: Int = 0
    
    @IBOutlet weak var mapView: MKMapView!
    
    // Asset to be displayed - can be NIL when called
    //var asset: PHAsset?
    
    // returns the current asset from the indexPosition and Album Collection
    func getAsset() -> PHAsset {
        
        if(phAssetResult.count > 0){
            return phAssetResult.object(at: indexPosition) as PHAsset
        } else {
            print("Warning: No image. swichting to backup image")
            return PHAsset();
        }
        

    }
    
    let zoomFactor = 2.5
    let screenWidth = 1920
    let screenHeight = 1080
    
    
    // The cells zoom when focused.
    var zommedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: CGFloat(self.zoomFactor), y: CGFloat(self.zoomFactor))
    }
    
    // The cells zoom when focused.
    var normalTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    
    
    // by default zoom is off
    var isZoomMode: Bool = false

    
    var initialCenterX: CGFloat = 0
    var initialCenterY: CGFloat = 0
    
    var baseCenterX: CGFloat = 0
    var baseCenterY: CGFloat = 0
    
    // standard primary image view
    @IBOutlet weak var imageView: UIImageView!
    
    // secondary image view
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBAction func buttonAction(_ sender: UIButton) {

        print("Restoration Identifier in DetailContoller \(restorationIdentifier)")
     
        
        // TRAILING CLOSURE
        dismiss(animated: true){
            print("dismissed")
            return
            
        }

        
        
    }
    
    // variables to detect double touch/tap
    // time when the touch happenend
    var touchBeginTime: CFTimeInterval = CACurrentMediaTime()
    var touchEndedTime: CFTimeInterval = CACurrentMediaTime()
    var clickCount  = 0
    
    // maximum time the finger can rest on the trackpad and after raising to count this as a tap
    let maxTouchTime = 0.4
    
    // maximum pause time between a double tap
    let maxPauseIntervalForTupleTap = 0.4
    
    // was the finger accidently moved, so that this is not a tap but a move?
    var hasMoved: Bool = false
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
      print("touches began")
        
        touchBeginTime = CACurrentMediaTime()
        hasMoved = false;
        

        // check if possible double candidate or just fail
        if(clickCount > 0){
            
            print("check for double click criteria")
           // var currentTime: CFTimeInterval = CACurrentMediaTime()
            
            // check if we have spend to much time between this and the last click
            if(touchBeginTime - touchEndedTime > maxPauseIntervalForTupleTap){
                clickCount = 0
                print("double touch not possible - due timeout")
            }
        }

        return
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesMoved(touches, with: event)
        
        // reset our doubleclick counter and movement
        
        hasMoved = true
            var clickCount  = 0
        
      //  print("touches moved")
        return
    }
    
    
    // MARK: DYANMIC SYSTEM STUFF
    
    var animator: UIDynamicAnimator?
    var currentLocation: CGPoint?
    var attachment: UIAttachmentBehavior?
    var attachment2: UIAttachmentBehavior?
    
    var snap: UISnapBehavior?
    
    // now boot the dynamic system
    func addDynamics(){
        animator =   UIDynamicAnimator(referenceView: self.view)
    
    //    let gravity = UIGravityBehavior(items: [imageView])
        
        // not needed as stated in current documentation
        // let vector = CGVector(dx: 0.0, dy: 1.0)
        // gravity.gravityDirection = vector
        
      //  animator?.addBehavior(gravity)

    
    }
    
 
    // remove the dynamic system
    func removeDynamics(){
        //animator =   UIDynamicAnimator(referenceView: self.view)
        
        
        animator?.removeAllBehaviors()
    }
 
    
    func setPreviewLeft(){
        
        // remove old dynamic behaviour
        if let behaviour=attachment2{
            animator?.removeBehavior(behaviour)
        }
        
        
    
        // hide the imageview while setting the stage
        imageView2.alpha = 0.0
        
        // set the boundaries for the image on the left side
        imageView2.frame = CGRect(x: -screenWidth  , y: 0, width: screenWidth, height: screenHeight)
        
        
        // load the image - currently only dummy
        // previous image
        imageView2.image = UIImage(named: "AppleTV-Icon-App-Large-1280x768")
        
        // activate it
        imageView2.alpha = 1.0
        
        
        // enable dynamic system
        var itemBehaviourPreview: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [imageView2])
        itemBehaviourPreview.elasticity = 1
        itemBehaviourPreview.density = 2
       // animator?.addBehavior(itemBehaviourPreview)
        
        // make the attachment not a bit off the center to provide some rotation
        attachment2 = UIAttachmentBehavior(item: imageView2!, offsetFromCenter: UIOffsetMake(0, 20),
                                           attachedToAnchor: CGPoint(x: -(screenWidth / 2) , y: screenHeight / 2 ))
        // create the intial attachment
        animator?.addBehavior(attachment2!)
        
        // preview image setup is done for state left
        previewMode = previewStates.initializedLeft
        print("preview image positioned on the left")
    }
    
    
    func setPreviewRight(){
        
        // remove old dynamic behaviour
        if let behaviour=attachment2{
            animator?.removeBehavior(behaviour)
        }
        
        
        // hide the imageview while setting the stage
        imageView2.alpha = 0.0
        
        // set the boundaries for the image on the left side
        imageView2.frame = CGRect(x: screenWidth , y: 0, width: screenWidth, height: screenHeight)
        
        
        // load the image - currently only dummy
        // next image
        imageView2.image = UIImage(named: "AppleTV-Icon-App-Large-1280x768")
        
        // activate it
        imageView2.alpha = 1.0
        
        
        // enable dynamic system
        var itemBehaviourPreview: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [imageView2])
        itemBehaviourPreview.elasticity = 1
        itemBehaviourPreview.density = 2
       // animator?.addBehavior(itemBehaviourPreview)
        
        // make the attachment not a bit off the center to provide some rotation
        attachment2 = UIAttachmentBehavior(item: imageView2!, offsetFromCenter: UIOffsetMake(0, 20),
                                           attachedToAnchor: CGPoint(x: screenWidth + (screenWidth / 2) , y: screenHeight / 2 ))
        // create the intial attachment
        animator?.addBehavior(attachment2!)
        
        
        
        // preview image setup is done for state right
        previewMode = previewStates.initiailzedRight
        print("preview image positioned on the right")
    
    }
    
    
    // MARK: Handling of movement when zoomed out
    func dynamicPan(_ recognizer: UIPanGestureRecognizer){
        
        
        // add the dynamic system initially
        // for later movement in the "changed" phase
        // release the anchors later in "ended"
        if (recognizer.state == UIGestureRecognizerState.began){
            
            // we are starting a new animation so
            // reset all dynamic animations and setup it like a new stage
            animator?.removeAllBehaviors()
            
            
            // get the x and y coordinates of the panning gesture
            // dampen a bit the x translation
            // and avoid division by zero
            var transX = recognizer.translation(in: view).x
            if(transX != 0){
                transX =  transX / 2
            }
            // we don´t want to have much y movement
            // since the images should be swiped left or right
            // and avoid division by zero
            var transY = recognizer.translation(in: view).y
            if(transY != 0){
                transY =  transY / 3
            }
            
            
            // moving to the right, so assume to get the previous image
            // set up the preview image if it hasn´t been done
            if(transX > 0  &&  previewMode != previewStates.initializedLeft){
                setPreviewLeft()
                
            }
            
            
            
            // moving to the left, so assume to get the next image
            // set up the preview image if it hasn´t been done
            if(transX < 0  &&  previewMode != previewStates.initiailzedRight){
                setPreviewRight()
            }
            
            
            
            var itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [imageView])
            itemBehaviour.elasticity = 1
            itemBehaviour.density = 2
            
            animator?.addBehavior(itemBehaviour)
            

            
           currentLocation = CGPoint(x: initialCenterX +  transX, y: initialCenterY + transY )
            
            
            
            
            
            // make the attachment a bit off the center to provide some rotation
            attachment = UIAttachmentBehavior(item: imageView!, offsetFromCenter: UIOffsetMake(0, -50),
                                              attachedToAnchor: currentLocation!)
            
            
            
            
            animator?.addBehavior(attachment!)

            
        }
        

        if (recognizer.state == UIGestureRecognizerState.changed){
            
            // get the x and y coordinates of the panning gesture
            // dampen a bit the x translation
            // and avoid division by zero
            var transX = recognizer.translation(in: view).x
            if(transX != 0){
                transX =  transX / 2
            }
            // we don´t want to have much y movement
            // since the images should be swiped left or right
            // and avoid division by zero
            var transY = recognizer.translation(in: view).y
            if(transY != 0){
                transY =  transY / 3
            }
            

            // direction change and we have to reset the preview image position?
            if(transX > 0  &&  previewMode == previewStates.initiailzedRight){
                setPreviewLeft()
                
            }
            
            
            // direction change and we have to reset the preview image position?
            if(transX < 0  &&  previewMode == previewStates.initializedLeft){
                setPreviewRight()
                
            }
            
            
            
            // move preview image from left
            if(transX > 0  &&  previewMode == previewStates.initializedLeft){
                
                
                var previewLocation: CGPoint = CGPoint(x: Int(transX) - (screenWidth / 2), y: screenHeight / 2 )
                attachment2?.anchorPoint = previewLocation
            }
            
            
            // move preview image from right
            if(transX < 0  &&  previewMode == previewStates.initiailzedRight){
                
             
                
                var previewLocation: CGPoint = CGPoint(x:  screenWidth + (screenWidth / 2) + Int(transX), y: screenHeight / 2 )
                attachment2?.anchorPoint = previewLocation
            }
            
            

          
            // show the next or previous image as a sneak preview
            // on the left or right
            //movePreviewImage(offsetX: Int(transX))
            
            currentLocation = CGPoint(x: initialCenterX + transX, y: initialCenterY + transY  )
            attachment?.anchorPoint = currentLocation!
            
            
            
            
            
        }
        
        
        
        
        if (recognizer.state == UIGestureRecognizerState.ended){
        
                animator?.removeBehavior(attachment!)
  //             animator?.removeBehavior(attachment2!)
            
            
            print("Speed X: \(recognizer.velocity(in: view).x)")
            
            let velX: CGFloat = recognizer.velocity(in: view).x
            let velY: CGFloat = recognizer.velocity(in: view).y
            
            
            // keep moving when the velocity is high enough
            // next image
            if(velX > 1000){
                
                print("speed reached")
                let gravity = UIGravityBehavior(items: [imageView])
                
                
           
                gravity.gravityDirection = CGVector(dx: velX / 100, dy: velY / 100)
                
                animator?.addBehavior(gravity)
               
                
                // append an action to the gravity
                // to observe if the image was moved 
                // off the visible screen and can be replaced by the previous image
                gravity.action = { _ in
                    if (self.imageView.center.x > CGFloat(self.screenWidth * 2) ){
                        print("off screen for previous image")
                        self.animator?.removeAllBehaviors()
                        self.isZoomMode = false;
                        self.loadPreviousImage()
                 
                        self.imageView.transform = self.normalTransform
                        self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
                        //self.imageView.alpha = 0
                        
                       /* UIView.animate(withDuration: 2,
                                       delay: 0,
                                       usingSpringWithDamping: 0.10,
                                       initialSpringVelocity: 0,
                                       options: .beginFromCurrentState,
                                       animations: { () -> Void in
                                        self.imageView.alpha = 1
                                        
                                        
                        }, completion: nil)
                        */
                    }
                    
             

                }
                
                return
                
            }
            
            
            
            // keep moving when the velocity is high enough
            // next image
            if(velX < -1000){
                
                print("NEGATIVE speed reached")
                let gravity = UIGravityBehavior(items: [imageView])
                
                
              //  gravity.gravityDirection = CGVector(dx: -1, dy: 0)
                gravity.gravityDirection = CGVector(dx: velX / 100, dy: velY / 100)
                
                animator?.addBehavior(gravity)
                
                
                // append an action to the gravity
                // to observe if the image was moved
                // off the visible screen and can be replaced by the next image
                gravity.action = { _ in
                    if (self.imageView.center.x < CGFloat(self.screenWidth * -2) ){
                        print("off screen for next image")
                        self.animator?.removeAllBehaviors()
                        self.isZoomMode = false;
                        self.loadNextImage()
                        self.imageView.transform = self.normalTransform
                        self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
                        
           
                        
                        
                    }
                    
                    
                    
                }
                
                return
                
            }
            
            
            // default case - just snap back
                snap = UISnapBehavior(item: imageView, snapTo: CGPoint(x: initialCenterX, y: initialCenterY))
                snap?.damping =  2
                animator?.addBehavior(snap!)
 
            
            if(previewMode == previewStates.initializedLeft){
                
                // remove old dynamic behaviour
                if let behaviour=attachment2{
                    animator?.removeBehavior(behaviour)
                }
            
                // snap back also the preview image
                // default case - just snap back
                var snapPreview: UISnapBehavior = UISnapBehavior(item: imageView2, snapTo: CGPoint(x: -(screenWidth / 2), y: screenHeight / 2 ))
                 snapPreview.damping =  2
                    animator?.addBehavior(snapPreview)
                print("snap back preview left")
                
            }
            

            
            if(previewMode == previewStates.initiailzedRight){
                // remove old dynamic behaviour
                if let behaviour=attachment2{
                    animator?.removeBehavior(behaviour)
                }
                // snap back also the preview image
                // default case - just snap back
                var snapPreview: UISnapBehavior = UISnapBehavior(item: imageView2, snapTo: CGPoint(x:  screenWidth + (screenWidth / 2) , y: screenHeight / 2 ))
                snapPreview.damping =  2
                animator?.addBehavior(snapPreview)
                print("snap back preview right")
            }
            
            
            
            
 
            
            
            
            
        }
        

        
    }
    
    
    
    func switchZoomMode(){
        
        let imageFrame = imageView.frame
        
        //print("ImageView size: \(imageFrame)")
        //print("Image size \(imageView.image?.size)")
        
        //print("ImageView center: \(imageView.center)")
        
        // zoom in or zoom out
        if(isZoomMode){
            isZoomMode = false
            print("Zoom disabled")
            
            // add dynamic system
            addDynamics()
            
            
            // zoom out
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState,
                           animations: { () -> Void in
                            self.imageView.transform = self.normalTransform
                            self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
            }, completion: nil)
            
            
        } else {
            isZoomMode = true
            print("Zoom enabled")
            
            
            // add dynamic system to avoid animation issues with the 
            // upcoming ui animation of the image
            removeDynamics()
            
            // zoom in
            
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState,
                           animations: { () -> Void in
                            self.imageView.transform = self.zommedTransform

                            
            }, completion: nil)
            
            
        }
    }
    
    
    
    func doubleTouch(){
        print("<< TOUCH TAB DOUBLE >>")
        switchZoomMode()

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
                    super.touchesEnded(touches, with: event)
        print("touches ended")
        

        

        
        
        if(!hasMoved){
            print ("finger was not moved")
            
            // do we have a double tap?
            
    
            
            
            touchEndedTime = CACurrentMediaTime()
            
            print("Interval \(touchEndedTime - touchBeginTime)")
            
            // touch too long the touch pad? then ignore it
            if(touchEndedTime - touchBeginTime < maxTouchTime){
                print("<< TOUCH TAB GESTURE >>")
                clickCount = clickCount + 1
                
                if(clickCount == 1){
                                 //   print("<< TOUCH TAB SINGLE >>")
                }
                
                if(clickCount == 2){
                    //print("<< TOUCH TAB DOUBLE >>")
                    doubleTouch()
                }
                
                print ("touch tap count: \(clickCount) ")
                
            } else {
                // reset clickcount because the click took to long
                clickCount = 0
            }
        } else {
            // finger was moved to reset the counter
                  clickCount = 0
        }
        
        

        return
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?){
                    super.touchesCancelled(touches, with: event)
        
        print("touches cancelled")
        clickCount = 0
        hasMoved = true
        
        return
    }

    

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        

        if let reg = (gestureRecognizer as? UIPanGestureRecognizer){
        
            //print(reg.translation(in: view))
            //print(reg.velocity(in:  view))
        }
        

        // dont send gestures to sub views
        if (touch.view?.isDescendant(of: self.view))!{
            return false
        }
        return true
    }
    
    func loadNextImage(){
        indexPosition = indexPosition + 1
        
        if(phAssetResult.count > 0){
            
            // did we reach the end of the list, then switch to the start
            if(indexPosition == phAssetResult.count){
                indexPosition = 0
            }
            
        }
        
        loadImage()
    }
    
    
    func loadPreviousImage(){
        indexPosition = indexPosition - 1
        
        if(phAssetResult.count > 0){
            
            // did we reach the end of the list, then switch to the start
            if(indexPosition < 0){
                indexPosition = phAssetResult.count - 1
            }
            
        }
        
        loadImage()
    }
    
    
    // we have the signature as a tabrecognizer
    func clicked(_ recognizer: UITapGestureRecognizer ){
        print("clicked ah tabbed")
   
        loadNextImage()

    }
    
    
    // we have the signature as a panrecognizer
    func panned(_ recognizer: UIPanGestureRecognizer ){
        
            
        //print(recognizer.translation(in: view))
        
        //print(recognizer.velocity(in:  view))
        
        
        // do no image movement since we´re not in zoom mode
        if(!isZoomMode){
            
            // we are panning and moving the image not in
            // zoom mode so just reset our click/tap count by default
            // otherwise this could lead to confusing situations and change internally to zoom mode
            // print("resetting click count due panning in switch mode")
            clickCount = 0
            hasMoved = true
            dynamicPan(recognizer)
            
            return
        }
        
        
        /*
        var myFrame: CGRect = CGRect(x: 0,y: 0, width: 400, height: 500)
 */

        
        // this should directly read the position
        if (recognizer.state == UIGestureRecognizerState.began){
            
                    print("began")
            // save the old values when the pan gestures starts
            // and then everything is relative
            
            baseCenterX = imageView.center.x
            baseCenterY = imageView.center.y
            
           }
        
            // MARK: Changed Panning
        if (recognizer.state == UIGestureRecognizerState.changed){
            
            //print("changed")
            
            // get the translation coordinates
            // and slow down or multiply the speed
            var trackpadX = recognizer.translation(in: view).x
            if(trackpadX != 0){
                trackpadX = trackpadX / 1.0
            }
            var trackpadY = recognizer.translation(in: view).y
            if(trackpadY != 0){
                trackpadY = trackpadY / 1.0
            }
            
            // set new position based on touch input
            
            let myFrame: CGRect = CGRect(x: trackpadX,y: trackpadY,
                                         width: imageView.bounds.size.width,
                                         height: imageView.bounds.size.height)
            

            
            // center x
            var x = baseCenterX + trackpadX;
            
            
            
            
            x = getSafeXCenter(x: x)
            //print("current x \(x)")
            
            
            var y = baseCenterY + trackpadY;
            

            y = getSafeYCenter(y: y)

            
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 0,
                         //  options: .beginFromCurrentState,
                         //  options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction
                            options: [.beginFromCurrentState],
                           animations: { () -> Void in
                                self.imageView.center = CGPoint(x: x, y: y)
                            
                            },
                           completion: nil)
            
            
        }
 
    
        // END OF MOVEMENT
        // MARK: End of Gesture
        
        if (recognizer.state == UIGestureRecognizerState.ended){
            
                        print("gesture ended")
                    print("Velocity: \(recognizer.velocity(in:  view))")
            
            
            
            var velX: CGFloat = recognizer.velocity(in: view).x
            var velY: CGFloat = recognizer.velocity(in: view).y
            
            
            // dampen the velocity
            if(velX !=  0){
                velX = velX / 10.0
            }
            
            // velocity is too fast
            if(velX > 2000){
                velX = 200
            }
            
            
            
            if(velY != 0){
                velY = velY / 10.0
            }
            
            // velocity is too fast
            if(velY > 2000){
                velY = 200
            }
            
            
            // update new base center based on velocity target
            // still need to validate the target for maximum position!
            baseCenterX = imageView.center.x + velX
            baseCenterY = imageView.center.y + velY
            
            
            
            baseCenterX = getSafeXCenter(x: baseCenterX)
            baseCenterY = getSafeYCenter(y: baseCenterY)
            
            UIView.animate(withDuration: 4,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 6,
                           options: [.beginFromCurrentState],
                           animations: { () -> Void in
                                self.imageView.center = CGPoint(x: self.baseCenterX, y: self.baseCenterY)
                           },
                           completion: nil)
            
                    print("End Coordiantes (\(initialCenterX), \(initialCenterY))")
    
        
        }

    }
    
    
    
    //check the bounds based on the zoom factor
    
    func getSafeXCenter(x: CGFloat) -> CGFloat {
        //print("Image size \(imageView.image?.size)")
    
        var newX = x;
        
        // could crash...
        //let imageWidth = imageView.image!.size.width
        //let displayImageWidth = imageView.bounds.width
        let displayImageWidth = displayedImageBounds().width
        
        
        
        
        let min: CGFloat
        let max: CGFloat
        
        // scaled image is smaller than screensize
        if( displayImageWidth*CGFloat(zoomFactor) <=  CGFloat(screenWidth) ){
            min = displayImageWidth*CGFloat(zoomFactor) / 2
            max = CGFloat(screenWidth) - displayImageWidth*CGFloat(zoomFactor) / 2
        // scaled image is larger than screensize
        } else {
            min = CGFloat(screenWidth) - displayImageWidth*CGFloat(zoomFactor) / 2
            max = displayImageWidth*CGFloat(zoomFactor) / 2
        }

        
        // check the boundaries
        // add some frame butter
        if(x <= min){
            newX =  min
        }
        
        if(x > max){
            newX = max
        }
        
       // print("safe x \(x) min: \(min) max: \(max) ")
        return newX
    }
    
    
    
    
    
    func getSafeYCenter(y: CGFloat) -> CGFloat {
        //print("Image size \(imageView.image?.size)")
        
        var newY = y;
        
        // could crash...
        //let imageHeight = imageView.image!.size.height
        //let displayImageHeight = imageView.bounds.height
        let displayImageHeight = displayedImageBounds().height
        
        let min: CGFloat
        let max: CGFloat
        
        // scaled image is smaller than screensize
        if( displayImageHeight*CGFloat(zoomFactor) <=  CGFloat(screenHeight) ){
            min = displayImageHeight*CGFloat(zoomFactor) / 2
            max = CGFloat(screenHeight) - displayImageHeight*CGFloat(zoomFactor) / 2
            // scaled image is larger than screensize
        } else {
            min = CGFloat(screenHeight) - displayImageHeight*CGFloat(zoomFactor) / 2
            max = displayImageHeight*CGFloat(zoomFactor) / 2
        }
        
        
        // check the boundaries
        // add some frame butter
        if(y <= min){
            newY =  min
        }
        
        if(y > max){
            newY = max
        }
        
       // print("safe y \(y) min: \(min) max: \(max) ")
        return newY
    }
    

    func loadImage(){

        
        
        // load the asset image for the detail view
        
    
        
        let imageManager = PHCachingImageManager()
        var imageSize: CGSize
        
        let imageFrame = imageView.frame
        
        
        print("size width: \(imageFrame.width) height: \(imageFrame.height)")
        let scale = UIScreen.main.scale
        
        
        
        imageSize = CGSize(width: (imageFrame.width) * scale, height: (imageFrame.height) * scale)
        
        print("trying to load assed: \(getAsset())")
        
        
        print("asset mediatype: \(getAsset().mediaType)")
        print("asset mediasubtype: \(getAsset().mediaSubtypes)")
        print("asset location: \(getAsset().location)")
        print("asset creation date: \(getAsset().creationDate)")
        
        
        infoTextView.text = "creation date: \(getAsset().creationDate) \nlocation: \(getAsset().location)"
        
        // better photo fetch options
        let options: PHImageRequestOptions = PHImageRequestOptions()
        
        // important for loading network resources and progressive handling with callback handler
        options.isNetworkAccessAllowed = true
        
        /*
         opportunistic
         Photos automatically provides one or more results in order to balance image quality and responsiveness.
         case highQualityFormat
         Photos provides only the highest-quality image available, regardless of how much time it takes to load.
         case fastFormat
         */
        
        //
        //options.deliveryMode = .opportunistic
        options.deliveryMode = .highQualityFormat
        
        // latest version of the asset
        options.version = .current
        
        // only on async the handler is being requested
        // TODO: Warning isSync FALSE produces currently unwanted errors for image loading
        options.isSynchronous = true
        
        let handler : PHAssetImageProgressHandler = { (progress, error, stop, info) in
            // your code
            DispatchQueue.main.async {
                print("---------------------------------------------==============")
                print("progress \(progress)")
                print("error \(error)")
                print("stop \(stop)")
                print("info \(info)")
            }
        }
        
        options.progressHandler = handler
        
        
        if (getAsset().location != nil){
            mapView.isHidden = false
            
            // zoom of map in meters
            let regionRadius: CLLocationDistance = 200
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(getAsset().location!.coordinate,
                                                                      regionRadius, regionRadius)
            mapView!.setRegion(coordinateRegion, animated: true)
            
            

            
            // remove all old annotations
            mapView.removeAnnotations(mapView.annotations)
            
            // pin the current annotation
            //var pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(your latitude, your longitude)
            let objectAnnotation = MKPointAnnotation()
            objectAnnotation.coordinate = getAsset().location!.coordinate
            
            //objectAnnotation.title = your title
            
            mapView.addAnnotation(objectAnnotation)
            
            
            //print("setting map on location \(getAsset().location)")
        } else {
            mapView.isHidden = true
        }
        
    
        // MARK: Display Metadata
        
        // Request an image for the asset from the PHCachingImageManager.
            //  cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: getAsset(), targetSize: imageSize, contentMode: .aspectFit, options: options, resultHandler: { imageResult, infoArray in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                
                // general information about the loaded asset
                //print("Load information \(infoArray)")
                // HERE WE GET THE IMAGE
                if(imageResult == nil){
                    print("============= error loading image =========================")
                    return
                }
                
                self.imageView.image = imageResult
                
                //self.imageView.image = image! as UIImage
                print("detail image was loaded")
            })
 
            

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialCenterX = imageView.center.x
        initialCenterY = imageView.center.y
        
        print("--------------------- Initial Coordiantes (\(initialCenterX), \(initialCenterY))")
        
        
        // add tap gesture for a click to get next photo
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clicked) )
        view.addGestureRecognizer(tapRecognizer)
        
        
   
        
        
        
        loadImage()
        
        mapView.layer.masksToBounds = false;
        mapView.layer.shadowOffset = CGSize(width:15, height:15);
        mapView.layer.shadowRadius = 5;
        mapView.layer.shadowOpacity = 0.2;
        mapView.layer.cornerRadius = 16
        
        
        
        // add pan gesture recognizer
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(panned) )
        view.addGestureRecognizer(panRec)
        
        addDynamics()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // get the real image coordinates of the embedded image
    // the UIimage in the UIimage view is fit via the aspect ratio
    // and may render differently on the per pixel screens
    func displayedImageBounds() -> CGRect {
        
        let boundsWidth = imageView.bounds.size.width
        let boundsHeight = imageView.bounds.size.height
        let imageSize = imageView.image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRect(x: topLeftX, y: 0, width: width, height: boundsHeight)
        }
        let scale = boundsWidth / imageSize.width
        let height = scale * imageSize.height
        let topLeftY = (boundsHeight - height) * 0.5
        return CGRect(x: 0, y: topLeftY, width: boundsWidth,height: height)
    }

    

}
