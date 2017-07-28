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
import CoreML
import Vision


class DetailController: UIViewController, UIGestureRecognizerDelegate {
    
    
    // core ML model
    var model: VNCoreMLModel!
    
    // defines the different states for the preview image
    // that slides in from left or right
    enum previewStatesEnum {
       
        case none  // uninitialized
        case initializedLeft  // left image was loaded and set ready
        case initiailzedRight // right image was loaded and set ready
        case snapToCenter     // trackpad was released before critical speed or
                              // movement position. snap back to default position
    }
    
    // current options for HUD display
    enum HUDModeEnum{
        case none  // no info HUD
        case standard
        case fullmap
    }
    
    // current HUD mode
    var HUDMode: HUDModeEnum = HUDModeEnum.none
    
    // callback navigation of the calling collection controller
    // to set the current navigation index path
    var presentingSmartController: SmartCollectionController?
    
    
    // safes the position of the main image
    // for backing in full screen mapview
    // to be restored on normal view
    var mainImageFrameBackup: CGRect?
    
    
    // to obtain the current mode of the preview image
    // for handling the gestures
    var previewMode: previewStatesEnum = previewStatesEnum.none
    
    
    // map recognizers to be restored for later navigation
    var mapRecoginzerArray: [UIGestureRecognizer]?
    
    // menubutton recognizer
    var menuRecognizer: UIGestureRecognizer?
    
    
    // is the image being changed to the next/last image
    // please do not dusturb the rendering
    var isImageTransition:Bool = false
    
    
    // collectionViewController as parent object
    // var collectionViewController: CollectionViewController?
    
    // loading info text for the user while getting the HQ detail image
    let loadingText = "🌻 loading..."
    
    // current asset list to be iterated through
    var phAssetResult: PHFetchResult<PHAsset>!
    
    // variable containing the current request id for 
    // the large async running image loader
    // this can be NIL when NO image is being loaded
    var imageAsyncRequestID: PHImageRequestID?
    
    // output labels for the image
    @IBOutlet weak var categoryHUD: UIVisualEffectView!
    @IBOutlet weak var category1Label: UILabel!
    @IBOutlet weak var category2Label: UILabel!
    
    
    // generic information HUD for loading next images
    @IBOutlet weak var infoLabel: UILabel!
    
    // status indicator when a background image is loading
    static var isLoadingProgress: Bool = false
    
    // current pointer in photo list
    @IBOutlet weak var infoTextView: UITextView!
    var indexPosition: Int = 0
    
    @IBOutlet weak var mapView: MKMapView!
    
    // displays the current showed photo number
    @IBOutlet weak var labelIndex: UILabel!
    
    // date information
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var metadataHUD: UIVisualEffectView!
    

    
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var labelFstop: UILabel!
    @IBOutlet weak var labelLength: UILabel!
    @IBOutlet weak var labelISO: UILabel!
    @IBOutlet weak var labelCamera: UILabel!
    @IBOutlet weak var labelLens: UILabel!
    
    /*
    // on leaving inform the calling view controller
    // of the cureent index position
    override func viewWillDisappear(_ animated: Bool) {
        print("view will disappear")
        
        // inform the presting collection controller
        // to update the index position
        // print(presentingSmartController)
     
    }
    */
    
    // returns the current asset from the indexPosition and Album Collection
    func getAsset() -> PHAsset {
        
        if(phAssetResult.count > 0){
            return phAssetResult.object(at: indexPosition) as PHAsset
        } else {
            print("Warning: No image. swichting to backup asset")
            return PHAsset();
        }
    }
    
    // returns the current asset from the indexPosition and Album Collection
    func getAsset(atIndex: Int) -> PHAsset {
        
        if(phAssetResult.count > 0){
            return phAssetResult.object(at: atIndex) as PHAsset
        } else {
            print("Warning: No image. swichting to backup image")
            return PHAsset();
        }
        
        
    }

    
    
    let zoomFactor = SettingsController.getZoomFactor()
    
    // adaptive calculation
    // should work on 720p, 1080 and 4k
    // convert to Int to calculate later better
    let screenWidth = Int(UIScreen.main.bounds.width)
    let screenHeight = Int(UIScreen.main.bounds.height)
    
    
    
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
     
        
        // currently full screen map - ignore all gestures
        if(HUDMode == .fullmap){
            return
        }
        
        
        
        // ignore while transition
        if(isImageTransition){
            return
            
        }
        
        touchBeginTime = CACurrentMediaTime()

        // important: reset the hasMoved status that we start a fresh 
        // analytics for the touch behaviour
        hasMoved = false;
        

        // check if possible double candidate or just fail
        if(clickCount > 0){
            
           // print("check for double click criteria")
           // var currentTime: CFTimeInterval = CACurrentMediaTime()
            
            // check if we have spend to much time between this and the last click
            if(touchBeginTime - touchEndedTime > maxPauseIntervalForTupleTap){
                clickCount = 0
                // print("double touch not possible - due timeout")
            }
        }

        return
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
            super.touchesMoved(touches, with: event)
       
        

        
        // reset our doubleclick counter and movement
        hasMoved = true
        //var clickCount  = 0
        
      //  print("touches moved")
        return
    }
    
    
    // MARK: DYANMIC SYSTEM STUFF
    
    var animator: UIDynamicAnimator?
    var currentLocation: CGPoint?
    var attachment: UIAttachmentBehavior?
    var attachment2: UIAttachmentBehavior?
    
    var gravity: UIGravityBehavior?
    
    var snap: UISnapBehavior?
    var snap2: UISnapBehavior?
    
    
    // now boot the dynamic system
    func addDynamics(){
        animator =   UIDynamicAnimator(referenceView: self.view)
    
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
        
        
        if let snap=snap2{
            animator?.removeBehavior(snap)
        }
    
        // hide the imageview while setting the stage
        imageView2.alpha = 0.0
        
        // reset to identity transform
        imageView2.transform = CGAffineTransform.identity
        
        
        // set the boundaries for the image on the left side
        imageView2.frame = CGRect(x: -screenWidth  , y: 0, width: screenWidth, height: screenHeight)
        
        
        // load the image - currently only dummy
        loadPreviousPreviewImage()
        
        // activate it
        imageView2.alpha = 1.0
        
        
        // enable dynamic system
        let itemBehaviourPreview: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [imageView2])
        itemBehaviourPreview.elasticity = 1
        itemBehaviourPreview.density = 2
       // animator?.addBehavior(itemBehaviourPreview)
        
        // make the attachment not a bit off the center to provide some rotation
        /*
        attachment2 = UIAttachmentBehavior(item: imageView2!, offsetFromCenter: UIOffsetMake(0, 5),
                                           attachedToAnchor: CGPoint(x: -(screenWidth / 2) , y: screenHeight / 2 ))
        
        */
        
        attachment2 = UIAttachmentBehavior(item: imageView2!, attachedToAnchor: CGPoint(x: -(screenWidth / 2) , y: screenHeight / 2 ))

        
        // create the intial attachment
        animator?.addBehavior(attachment2!)
        
        // preview image setup is done for state left
        previewMode = previewStatesEnum.initializedLeft
        //print("preview image positioned and loaded on the left")
    }
    
    
    func setPreviewRight(){
        
        // remove old dynamic behaviour
        if let behaviour=attachment2{
            animator?.removeBehavior(behaviour)
        }

        if let snap=snap2{
            animator?.removeBehavior(snap)
        }

        
        
        // hide the imageview while setting the stage
        imageView2.alpha = 0.0
        
        // reset to identity transform
        imageView2.transform = CGAffineTransform.identity
        
        // set the boundaries for the image on the left side
        imageView2.frame = CGRect(x: screenWidth , y: 0, width: screenWidth, height: screenHeight)
        
        
        // load the image - currently only dummy
        // next image
        //imageView2.image = UIImage(named: "AppleTV-Icon-App-Large-1280x768")
        loadNextPreviewImage()
        
        // activate it
        imageView2.alpha = 1.0
        
        
        // enable dynamic system
        let itemBehaviourPreview: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [imageView2])
        itemBehaviourPreview.elasticity = 1
        itemBehaviourPreview.density = 2
       // animator?.addBehavior(itemBehaviourPreview)
        
        // make the attachment not a bit off the center to provide some rotation
        /*
        attachment2 = UIAttachmentBehavior(item: imageView2!, offsetFromCenter: UIOffsetMake(0, 5),
                                           attachedToAnchor: CGPoint(x: screenWidth + (screenWidth / 2) , y: screenHeight / 2 ))
            */
        attachment2 = UIAttachmentBehavior(item: imageView2!,  attachedToAnchor: CGPoint(x: screenWidth + (screenWidth / 2) , y: screenHeight / 2 ))

        
 // create the intial attachment
        animator?.addBehavior(attachment2!)
        
        
        
        // preview image setup is done for state right
        previewMode = previewStatesEnum.initiailzedRight
        //print("preview image positioned and loaded on the right")
    
    }
    
    
    // MARK: Handling of movement when zoomed out
    func browseWithPanning(_ recognizer: UIPanGestureRecognizer){
        
        
        // image transition running to the next or last image
        // do not disturb
        if(isImageTransition){
           // print("image transition in process - do not disturb - ignoring events")
            return
        }
        
        
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
            if(transX > 0  &&  previewMode != previewStatesEnum.initializedLeft){
                setPreviewLeft()
                
            }
            
            
            
            // moving to the left, so assume to get the next image
            // set up the preview image if it hasn´t been done
            if(transX < 0  &&  previewMode != previewStatesEnum.initiailzedRight){
                setPreviewRight()
            }
            
            
            
            let itemBehaviour: UIDynamicItemBehavior = UIDynamicItemBehavior(items: [imageView])
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
            
            // moving to the right, so assume to get the previous image
            // set up the preview image if it hasn´t been done
            if(transX > 0  &&  previewMode != previewStatesEnum.initializedLeft){
                setPreviewLeft()
                
            }
            
            
            
            // moving to the left, so assume to get the next image
            // set up the preview image if it hasn´t been done
            if(transX < 0  &&  previewMode != previewStatesEnum.initiailzedRight){
                setPreviewRight()
            }
            
            
            
            // direction change and we have to reset the preview image position?
            if(transX > 0  &&  previewMode == previewStatesEnum.initiailzedRight){
                setPreviewLeft()
                
            }
            
            
            // direction change and we have to reset the preview image position?
            if(transX < 0  &&  previewMode == previewStatesEnum.initializedLeft){
                setPreviewRight()
                
            }
            
            
            
            // move preview image from left
            if(transX > 0  &&  previewMode == previewStatesEnum.initializedLeft){
                
                
                let previewLocation: CGPoint = CGPoint(x: Int(transX) - (screenWidth / 2), y: screenHeight / 2 )
                attachment2?.anchorPoint = previewLocation
            }
            
            
            // move preview image from right
            if(transX < 0  &&  previewMode == previewStatesEnum.initiailzedRight){
                
             
                
                let previewLocation: CGPoint = CGPoint(x:  screenWidth + (screenWidth / 2) + Int(transX), y: screenHeight / 2 )
                attachment2?.anchorPoint = previewLocation
            }
            
            

          
            // show the next or previous image as a sneak preview
            // on the left or right
            //movePreviewImage(offsetX: Int(transX))
            
            currentLocation = CGPoint(x: initialCenterX + transX, y: initialCenterY + transY  )
            attachment?.anchorPoint = currentLocation!
            
            
            
            
            
        }
        
        
        
        // MARK: Snap back or switch to next image
        if (recognizer.state == UIGestureRecognizerState.ended){
        
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
            if(transX > 0  &&  previewMode != previewStatesEnum.initializedLeft){
                setPreviewLeft()
                
            }
            
            
            // moving to the right, so assume to get the previous image
            // set up the preview image if it hasn´t been done
            if(transX > 0  &&  previewMode != previewStatesEnum.initializedLeft){
                setPreviewLeft()
                
            }
            
            
            
            // moving to the left, so assume to get the next image
            // set up the preview image if it hasn´t been done
            if(transX < 0  &&  previewMode != previewStatesEnum.initiailzedRight){
                setPreviewRight()
            }
            
            
            
                animator?.removeBehavior(attachment!)
  //             animator?.removeBehavior(attachment2!)
            
            
            // print("Speed X: \(recognizer.velocity(in: view).x)")
            
            var velX: CGFloat = recognizer.velocity(in: view).x
            let velY: CGFloat = recognizer.velocity(in: view).y
            
            
            // keep moving when the velocity is high enough
            // next image or the position is far enought away
            // snap back if an image is still loading...
            
            if(velX > 1500  || transX > 700 ){
                
                // cancel possible loading of background 
                // detail image that takes long 
                // and fade out HUD
                cancelImageLoad()
                
              //  if(velX < 1000){
                    velX = 8000
               // }
                
                isImageTransition = true
                
                // reset the preview mode since we are loading a new image
                previewMode = previewStatesEnum.none
                
                // move the preview image into focus
                // remove old dynamic behaviour
                if let behaviour=attachment2{
                    animator?.removeBehavior(behaviour)
                }
                
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .beginFromCurrentState,
                               animations: { () -> Void in
                               self.imageView2.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 2 )
                },
                               completion: nil)
                
                
                /*
                // snap back also the preview image
                // default case - just snap back
                snap2 = UISnapBehavior(item: imageView2, snapTo: CGPoint(x: screenWidth / 2, y: screenHeight / 2 ))
                snap2?.damping =  5
                //snap2?.damping =  1.3
                
                animator?.addBehavior(snap2!)
                */
                
                
                // reset the preview mode since we are loading a new image
                previewMode = previewStatesEnum.none
                ///////////////////////////////////////
                
                
                // print("speed for image switching reached")
                gravity = UIGravityBehavior(items: [imageView])
                
                
           
                gravity?.gravityDirection = CGVector(dx: velX / 100, dy: velY / 100)
                
                animator?.addBehavior(gravity!)
               
                
                // append an action to the gravity
                // to observe if the image was moved 
                // off the visible screen and can be replaced by the previous image
                gravity!.action = { () in
                    if (self.imageView.center.x > CGFloat(self.screenWidth * 4) ){
                        //print("off screen for previous image")
                        
                        
                        self.animator?.removeAllBehaviors()
                        
                        self.isZoomMode = false;
                        
                        // hide the last original image to avoid flickering
                        self.imageView.image = nil
                        
                        self.loadPreviousImage()

                        
                        
                        
                       // self.imageView.transform = self.normalTransform
                        self.imageView.transform = CGAffineTransform.identity
                        
                        
                        // self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
                        
                       /* UIView.animate(withDuration: 2,
                                       delay: 0,
                                       usingSpringWithDamping: 0.10,
                                       initialSpringVelocity: 0,
                                       options: .beginFromCurrentState,
                                       animations: { () -> Void in
                                        self.imageView.alpha = 1
                                        
                                        
                        }, completion: nil)
                        */
                        self.isImageTransition = false
                    }
                    
             

                }
                
                return
                
            }
            
            
            
            // keep moving when the velocity is high enough
            // next image or the position is far enought away
            // snap back if an image is still loading...
            
            if(velX < -1500 || transX < -700){
                
                // cancel possible loading of background
                // detail image that takes long
                // and fade out HUD
                cancelImageLoad()
                
                
               // if(velX > -1000){
                    velX = -8000
               // }
                
                isImageTransition = true
                
                // reset the preview mode since we are loading a new image
                previewMode = previewStatesEnum.none
                
                //print("NEGATIVE speed reached")
                
                // move the preview image into focus
                // remove old dynamic behaviour
                if let behaviour=attachment2{
                    animator?.removeBehavior(behaviour)
                }
                
                /*
                // snap back also the preview image
                // default case - just snap back
                snap2 = UISnapBehavior(item: imageView2, snapTo: CGPoint(x: screenWidth / 2, y: screenHeight / 2 ))
                //snap2?.damping =  1.3
                snap2?.damping = 5
                
                animator?.addBehavior(snap2!)
                */
                
                
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .beginFromCurrentState,
                               animations: { () -> Void in
                               self.imageView2.center = CGPoint(x: self.screenWidth / 2, y: self.screenHeight / 2 )
                },
                               completion: nil)
                
                // reset the preview mode since we are loading a new image
                previewMode = previewStatesEnum.none
                ///////////////////////////////////////
                
                
                
                let gravity = UIGravityBehavior(items: [imageView])
                
                
              //  gravity.gravityDirection = CGVector(dx: -1, dy: 0)
                gravity.gravityDirection = CGVector(dx: velX / 100, dy: velY / 100)
                
                animator?.addBehavior(gravity)
                
                
                // append an action to the gravity
                // to observe if the image was moved
                // off the visible screen and can be replaced by the next image
                gravity.action = { () in
                    if (self.imageView.center.x < CGFloat(self.screenWidth * -4) ){
                        //print("off screen for next image")
                        self.animator?.removeAllBehaviors()
                        self.isZoomMode = false;
                        
                        // hide the last original image to avoid flickering
                        self.imageView.image = nil
                        
                        self.loadNextImage()

                        
                    //    self.imageView.transform = self.normalTransform
                        self.imageView.transform = CGAffineTransform.identity
                        
                        self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
                           self.isImageTransition = false
           
                        
                        
                    }
                    
                    
                    
                }
                
                return
                
            }
            
            
            // default case - just snap back
            snap = UISnapBehavior(item: imageView, snapTo: CGPoint(x: initialCenterX, y: initialCenterY))
            snap?.damping =  2
            animator?.addBehavior(snap!)
 
            
            if(previewMode == previewStatesEnum.initializedLeft){
                
                // remove old dynamic behaviour
                if let behaviour=attachment2{
                    animator?.removeBehavior(behaviour)
                }
            
                // snap back also the preview image
                // default case - just snap back
                snap2 = UISnapBehavior(item: imageView2, snapTo: CGPoint(x: -(screenWidth / 2), y: screenHeight / 2 ))
                snap2?.damping =  2
                animator?.addBehavior(snap2!)
                
                // reset the preview mode since we are loading a new image
                previewMode = previewStatesEnum.none
                
                print("snap back preview left")
                
            }
            

            
            if(previewMode == previewStatesEnum.initiailzedRight){
                // remove old dynamic behaviour
                if let behaviour=attachment2{
                    animator?.removeBehavior(behaviour)
                }
                // snap back also the preview image
                // default case - just snap back
                snap2 = UISnapBehavior(item: imageView2, snapTo: CGPoint(x:  screenWidth + (screenWidth / 2) , y: screenHeight / 2 ))
                snap2?.damping =  2
                animator?.addBehavior(snap2!)
                
                // reset the preview mode since we are loading a new image
                previewMode = previewStatesEnum.none
                
                print("snap back preview right")
            }

            
        }
        

        
    }
    
    
    
    func switchZoomMode(){
    
        
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
                            //self.imageView.transform = self.normalTransform
                            self.imageView.transform =  CGAffineTransform.identity
                           
                            
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
        // print("<< TOUCH TAB DOUBLE >>")
        switchZoomMode()

        
    }
    
    // lowlevel API to check the touch state for our click listener
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
                    super.touchesEnded(touches, with: event)
        // print("touches ended")
        

        

        
        
        if(!hasMoved){
            //print ("finger was not moved")
            
            // do we have a double tap?
            
    
            
            
            touchEndedTime = CACurrentMediaTime()
            
            //print("Interval between taps \(touchEndedTime - touchBeginTime)")
            
            // touch too long the touch pad? then ignore it
            if(touchEndedTime - touchBeginTime < maxTouchTime){
            //    print("<< TOUCH TAB GESTURE >>")
                clickCount = clickCount + 1
                
                if(clickCount == 1){
                                 //   print("<< TOUCH TAB SINGLE >>")
                }
                
                if(clickCount == 2){
                    //print("<< TOUCH TAB DOUBLE >>")
                    doubleTouch()
                }
                
              //  print ("touch tap count: \(clickCount) ")
                
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
        
        //print("touches cancelled")
        clickCount = 0
        hasMoved = true
        
        return
    }

    
    // dont send gestures to sub views

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        

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
        
    

       
       
        // presentingSmartController?.setNeedsFocusUpdate()
        //presentingSmartController?.updateFocusIfNeeded()
        
        loadMainImage()
    }
    
    
    func loadPreviousImage(){
        indexPosition = indexPosition - 1
        
        if(phAssetResult.count > 0){
            
            // did we reach the end of the list, then switch to the start
            if(indexPosition < 0){
                indexPosition = phAssetResult.count - 1
            }
            
        }
        
        loadMainImage()
    }
    
    // aborts a running image request
    // and sets the HUD to default
    // to make a new loading slot free
    func cancelImageLoad(){
        if(DetailController.isLoadingProgress == true){
            hideLoadingHUD()
            
            if let id = imageAsyncRequestID{
           //     print("Aborting ImageRequestID \(id)")
                PHImageManager.default().cancelImageRequest(id)
              //  imageAsyncRequestID = nil
            }
            DetailController.isLoadingProgress = false
            
        }
        
    }
    
    
    // we have the signature as a tabrecognizer
//    @objc func clicked(_ recognizer: UITapGestureRecognizer ){
    @objc func clicked( recognizer: UITapGestureRecognizer ){
        
        // currently full screen map - ignore all gestures
        if(HUDMode == .fullmap){
            return
        }
        
        
        print("trackpad clicked")
   
        // abort any loading image - hopefully the imagemanager will accept this 
        // abortion request. but phimagemanager seems to decide on its own
        cancelImageLoad()
        
        loadNextImage()

    }
    
    
    // toggels the HUD states
    func toggleHUDState(){

        
        // restore recognizers
        // FULL MAP MODE
        
        // cycle through the mode
        
        switch HUDMode{
        case .none:
            
            print("none HUD -> standard HUD")
            

            
            // set to standard as follower
            HUDMode = .standard
       
            
            
            // start image detection classification, because this can take a time
         
            if(DetailController.isLoadingProgress == false){
                detectImage()
            }
            
            
            
            
            // restore the original location of the main image
            // if we were really in full screen mode
            // this only applies if the have a backupframe position
            // after restoring this location we set the backupframe
            // to NIL to be in an "unused" state
            if(getAsset().location != nil && mainImageFrameBackup != nil ){
                // change Z index for smoother visual transition
                view.sendSubview(toBack: self.imageView)
                
                // NILPOINTER BY MAINFRAME
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.imageView.frame = self.mainImageFrameBackup!  // ERROR: MIGHT BE NIL!!!
                    self.imageView.layer.shadowOffset = CGSize(width:15, height:15);
                    self.imageView.layer.shadowRadius = 0;
                    self.imageView.layer.shadowOpacity = 0.0;
                    
                }, completion: {
                    (ended) -> Void in
                    // send to back
                    self.view.sendSubview(toBack: self.imageView)
                    
                    // set the framebackup to NIL that other
                    // images are not confused
                    self.mainImageFrameBackup = nil
                })
            }
    
            // still possible to select the legal button? :)
            mapView.isUserInteractionEnabled = false
            mapView.isScrollEnabled = false
            mapView.isZoomEnabled = false


            showMetadataHUD()
            showMap()
            
            // ADD menu recognizer for escaping
      //      var m = UITapGestureRecognizer(target: self, action: #selector(menuPress(_:)) )
            

            view.addGestureRecognizer(menuRecognizer!)
            
            
        case .standard:

            
            // we don´t have a location
            // just send back to NO overlay display
            if(getAsset().location == nil){
                print("no GPS available. send back to normal")
                // go to previous mode mode
                HUDMode = .none
                hideMetadataHUD()
                hideCategoryHUD()
                hideMap()
                  print("standard HUD -> no HUD")
                
                // REMOVE MENU RECOGNIZER
                view.removeGestureRecognizer(menuRecognizer!)
                return
            }
            
            print("standard HUD -> fullmap HUD")

            
            // next mode
            HUDMode = .fullmap
            
            // backup the original location of the main image
            mainImageFrameBackup = imageView.frame
            

            

            
            
            // bring to front
            self.view.bringSubview(toFront: self.imageView)
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.imageView.frame = CGRect(x: 0 , y: 20, width: 350  ,  height: 250  )
                self.imageView.layer.shadowOffset = CGSize(width:15, height:15);
                self.imageView.layer.shadowRadius = 5;
                self.imageView.layer.shadowOpacity = 0.5;
                
                
            })
            
            
            
            // hideMetadataHUD()
            
            mapView.isUserInteractionEnabled = true
            mapView.isScrollEnabled = true
            mapView.isZoomEnabled = true
            
            
            /*
             for rec in mapRecoginzerArray!{
             
             mapView.removeGestureRecognizer(rec)
             }
             */
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.mapView.frame = CGRect(x: 0 , y: 0, width: self.screenWidth  ,  height: self.screenHeight  )
                //    self.mapView.layoutIfNeeded()
            })
            
            
            
        case .fullmap:
            print("fullmap HUD -> none HUD")
            
            // set to none as follower
            // fade out mapview
            // Back to basics
            HUDMode = .none
            
            // restore the original location of the main image
            // if we were really in full screen mode
            // this only applies if the have a backupframe position
            // after restoring this location we set the backupframe
            // to NIL to be in an "unused" state

            if(getAsset().location != nil && mainImageFrameBackup != nil ){
                // NILPOINTER BY MAINFRAME
                print("getting to main backup frame")
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.imageView.frame = self.mainImageFrameBackup!  // ERROR: MIGHT BE NIL!!!
                    self.imageView.layer.shadowOffset = CGSize(width:15, height:15);
                    self.imageView.layer.shadowRadius = 0;
                    self.imageView.layer.shadowOpacity = 0.0;
                    
                }, completion: {
                    (ended) -> Void in
                    // send to back
                    self.view.sendSubview(toBack: self.imageView)
                    // set the framebackup to NIL that other
                    // images are not confused
                    self.mainImageFrameBackup = nil
                })
            }

            
            
      
            

            
            
            // REMOVE MENU RECOGNIZER
            view.removeGestureRecognizer(menuRecognizer!)
           
            
            hideMetadataHUD()
            hideCategoryHUD()
            
            // still possible to select the legal button? :)
            mapView.isUserInteractionEnabled = false
            mapView.isScrollEnabled = false
            mapView.isZoomEnabled = false
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.mapView.frame = CGRect(x:  1475  , y: 714 , width:425 ,  height: 346)
                self.mapView.alpha = 0
                //self.mapView.layoutIfNeeded()
                
            }, completion: {
                (ended) -> Void in
                self.mapView.isHidden = true
            })
            
            
            
        }

        
        
    }
    
    
    @objc func doubleClickPlay(){
        print("double click play")
        
        toggleHUDState()
        
    }
   
    
    
    @objc func longPressSelect(_ recognizer: UIGestureRecognizer){
        
        
        if(recognizer.state == .began){
            print("long press select")
            
                    let alertController = UIAlertController(title: "Choose an Action", message: "Tip: You can use the trackpad for navigation and double click / long press the Play button to toggle the Info HUD.", preferredStyle: .actionSheet)
            
            if(HUDMode != .fullmap){
                
                if(isZoomMode){
                    let zoomOutAction = UIAlertAction(title: "🔍 Standard Zoom", style: .default, handler:{
                        (action:UIAlertAction) -> Void in
                        
                        self.switchZoomMode()
                    })
                    alertController.addAction(zoomOutAction)
                    
                } else {
                    let zoomInAction = UIAlertAction(title: "🔍 \(zoomFactor)x Zoom", style: .default, handler:{
                        (action:UIAlertAction) -> Void in
                        
                        self.switchZoomMode()
                    })
                    alertController.addAction(zoomInAction)
                    
                }
                
            }
            
            
            if(HUDMode == .fullmap){
                let toggleHUD = UIAlertAction(title: "🗺 Exit Map", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                
                    self.toggleHUDState()
                })
            
                alertController.addAction(toggleHUD)
            }
         
            if(HUDMode == .standard && getAsset().location != nil){
                let hideHUD = UIAlertAction(title: "📷 Hide Infos", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                    
                    
                    self.HUDMode = .fullmap
                    self.toggleHUDState()
                })
                
                alertController.addAction(hideHUD)
            }

            
            if(HUDMode == .standard && getAsset().location == nil){
                let hideHUD = UIAlertAction(title: "📷 Hide Infos", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                    
                    self.toggleHUDState()
                })
                
                alertController.addAction(hideHUD)
            }
            
            
            
     
            
    
            if(HUDMode == .none){
                let showHUD = UIAlertAction(title: "📷 Show Infos", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                    
                    self.toggleHUDState()
                })
                
                alertController.addAction(showHUD)
            }

            if(HUDMode == .none && getAsset().location != nil){
                let showFull = UIAlertAction(title: "🗺 Fullscreen Map", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                    //self.HUDMode = .standard
                    self.toggleHUDState()
                    self.toggleHUDState()
                })
                
                alertController.addAction(showFull)
            }
            
            
            
            if(HUDMode == .standard && getAsset().location != nil){
                let fullMAP = UIAlertAction(title: "🗺 Fullscreen Map", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                    
                    self.toggleHUDState()
                })
                
                alertController.addAction(fullMAP)
            }
            

            
            
            

            

            
            if(HUDMode != .fullmap){
                let nextAction = UIAlertAction(title: "Next Image", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
                    
                    self.loadNextImage()
                })
                alertController.addAction(nextAction)
                
                
                let previousAction = UIAlertAction(title: "Previous Image", style: .default, handler:{
                    (action:UIAlertAction) -> Void in
        
                    self.loadPreviousImage()
                })
                alertController.addAction(previousAction)

            }
            

            
            
            // do nothing
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            
            

          
            
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            //  print(    recognizer.state.rawValue)
            
        }
        
    }
   
    
    
    
    @objc func longPressPlay(_ recognizer: UIGestureRecognizer){
    
        
        if(recognizer.state == .began){
            print("long press play")
            toggleHUDState()
            
            
            
        } else {
            
          //  print(    recognizer.state.rawValue)
            
        }
        
    }
    
    // this is the emergency exit
    @objc func menuPress(_ recognizer: UILongPressGestureRecognizer){
        print("menu")
        // now go back an remove the menu listener
        // always go back
        
        if(HUDMode == .fullmap){
            // next HUDmode should be standard
            HUDMode = .none
            
            toggleHUDState()
                return
        }
        
        // ACHTUNG: kann in fullmap gehen obwohl das hauptbild noch nie geladen wurde. puh puh puh
            HUDMode = .fullmap

        
        toggleHUDState()
        
    }
    
    
    // callback method for the panrecognizer
    // to track the movements
    // while in normal or zoom mode
    
    
    @objc func panned(recognizer: UIPanGestureRecognizer ){
        
        // currently full screen map - ignore all gestures
        if(HUDMode == .fullmap){
            return
        }
            
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
            browseWithPanning(recognizer)
            
            return
        }
        
  
        
        
        // this should directly read the position
        if (recognizer.state == UIGestureRecognizerState.began){
            
            //        print("began")
            
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
            

            
            // center x
            var x = baseCenterX + trackpadX;
            x = getSafeXCenter(x: x)
            
            
            var y = baseCenterY + trackpadY;
            

            y = getSafeYCenter(y: y)

            // move the image according to the trackpad movements
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
            
        
            //   print("Velocity: \(recognizer.velocity(in:  view))")
            
            
            
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
            
            // move the image and smoothen out the movement
            // with a duration 4 seconds
            UIView.animate(withDuration: 4,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 6,
                           options: [.beginFromCurrentState],
                           animations: { () -> Void in
                                self.imageView.center = CGPoint(x: self.baseCenterX, y: self.baseCenterY)
                           },
                           completion: nil)
            
                    // print("End Coordiantes (\(initialCenterX), \(initialCenterY))")
    
        
        }

    }
    
    
    
    //check the bounds based on the zoom factor
    
    func getSafeXCenter(x: CGFloat) -> CGFloat {
        //print("Image size \(imageView.image?.size)")
    
        var newX = x;
        
        // could crash...
        //let imageWidth = imageView.image!.size.width
        //let displayImageWidth = imageView.bounds.width
        let displayImageWidth = calculateScreenImageBounds().width
        
        
        
        
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
        let displayImageHeight = calculateScreenImageBounds().height
        
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
    
    
    // generic function that loads an image for the requested asset
    // add the requesting asset to load and provide an handler to use the image
    // returns the PHImageRequestID to e.g. cancel the request for long running tasks when other UXP action is needed
    @discardableResult func loadImage(asset: PHAsset, isSynchronous: Bool, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) -> PHImageRequestID{
        
        //let imageManager = PHCachingImageManager()
        let imageManager = PHImageManager.default()

        
        
        // better photo fetch options
        let options: PHImageRequestOptions = PHImageRequestOptions()
        
        // important for loading network resources and progressive handling with callback handler
        options.isNetworkAccessAllowed = true
        
        
        // loads one or more steps
        //options.deliveryMode = .opportunistic
        
        // only the highest quality available: only one call (!)
        // deliverymode is ignored on requestimagedata (!) method
        options.deliveryMode = .highQualityFormat
        
        // latest version of the asset
        options.version = .current
        
        // only on async the handler is being requested
        // TODO: Warning isSync FALSE produces currently unwanted errors for image loading
        options.isSynchronous = isSynchronous
        
        
        /*
        let handler : PHAssetImageProgressHandler = { (progress: Double, error: Error?, stop:UnsafeMutablePointer<ObjCBool> , info:[AnyHashable : Any]?) in
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
        */
        
        let requestID:PHImageRequestID = imageManager.requestImageData(for: asset, options: options, resultHandler: resultHandler)
        return requestID
    }
    
    
    
    
    func loadPreviousPreviewImage(){
        // load the asset image for the detail view
        
        
        var previewPosition: Int = indexPosition - 1
        
        if(phAssetResult.count > 0){
            
            // did we reach the end of the list, then switch to the start
            if(previewPosition < 0){
                previewPosition = phAssetResult.count - 1
            }
            
        }
        

        let asset: PHAsset = getAsset(atIndex: previewPosition)

        // discardable result
        _ = loadImage(asset: asset, isSynchronous: true, resultHandler:  { imageData, dataUTI, orientation, infoArray in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                
                // general information about the loaded asset
                //print("Load information \(infoArray)")
                // HERE WE GET THE IMAGE
                
                if(infoArray != nil){
                    if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                        if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                            print("============    DEGRADED: Setting no image     ============")
                            return
                        }
                        
                    }
                }
                
            if(imageData == nil){
                print("previous preview image is NIL: fallback image used")
                self.imageView2.image = UIImage(named: "taxcloud_hd")
                return
            }
            

            
                if let image = UIImage(data: imageData!){
                    
                    
                    self.imageView2.image = image

                    
                } else {
                    print("error creating image from data")
                }
                
        })
            
     
        // and full spec image to avoid the cloud
        _ = loadImage(asset: asset, isSynchronous: false, resultHandler:  { imageData, dataUTI, orientation, infoArray in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            
            
            // general information about the loaded asset
            //print("Load information \(infoArray)")
            // HERE WE GET THE IMAGE
            
            if(infoArray != nil){
                if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                    if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                        print("============    DEGRADED: Setting no image     ============")
                        return
                    }
                    
                }
            }
            
            
            
            if(imageData == nil){
                print("next preview image is NIL:")
                self.imageView2.image = UIImage(named: "taxcloud_hd")
                return
            }
            
            
            if let image = UIImage(data: imageData!){
                
                
                self.imageView2.image = image
                
                
            } else {
                print("error creating image from data")
            }
            
        })
        

    }

    
    
    func loadNextPreviewImage(){
        // load the asset image for the detail view
        
        
        var previewPosition: Int = indexPosition + 1
        
        if(phAssetResult.count > 0){
            
            // did we reach the end of the list, then switch to the start
            if(previewPosition == phAssetResult.count){
                previewPosition = 0
            }
            
        }
        
        
        let asset: PHAsset = getAsset(atIndex: previewPosition)


        // FAST loading of the preview
        // and or replacing it with highres version ;)
        
        _ = loadImage(asset: asset, isSynchronous: true, resultHandler:  { imageData, dataUTI, orientation, infoArray in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            
            
            // general information about the loaded asset
            //print("Load information \(infoArray)")
            // HERE WE GET THE IMAGE
            
            if(infoArray != nil){
                if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                    if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                        print("============    DEGRADED: Setting no image     ============")
                        return
                    }
                    
                }
            }
  


            if(imageData == nil){
                print("next preview image is NIL:")
                self.imageView2.image = UIImage(named: "taxcloud_hd")
                return
            }

            
            if let image = UIImage(data: imageData!){
                
                
                self.imageView2.image = image

                
            } else {
                print("error creating image from data")
            }
            
        })
        
        // and full spec image to avoid the cloud
        _ = loadImage(asset: asset, isSynchronous: false, resultHandler:  { imageData, dataUTI, orientation, infoArray in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            
            
            // general information about the loaded asset
            //print("Load information \(infoArray)")
            // HERE WE GET THE IMAGE
            
            if(infoArray != nil){
                if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                    if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                        print("============    DEGRADED: Setting no image     ============")
                        return
                    }
                    
                }
            }
            
            
            
            if(imageData == nil){
                print("next preview image is NIL:")
                self.imageView2.image = UIImage(named: "taxcloud_hd")
                return
            }
            
            
            if let image = UIImage(data: imageData!){
                
                
                self.imageView2.image = image
                
                
            } else {
                print("error creating image from data")
            }
            
        })

        
    }

    
    
    func hideMap(){
    
        
        mapView.isHidden = true
        
        /*
            UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                self.mapView.alpha = 0.0
            self.mapView.frame = CGRect(x:  1975  , y: 714 , width:100 ,  height: 100)
            })
        */
        
    }

    
    
    func showMap(){
        if(HUDMode == .none){
            
            // do nothing
            return
        }
        
                mapView.isHidden = false
        
        
        // MAP overlay display logic
        if (getAsset().location != nil){
            
            // fade in map and resize
            UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState,
                animations: {
                    self.mapView.alpha = 1.0
                    self.mapView.frame = CGRect(x:  1475  , y: 714 , width:425 ,  height: 346)
                }
            )
        

        
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
            
        } else {
            hideMap()
        }
  
    }


    
    func showPrefetchHUD(){
        // display prefetch status, but wait a bit in the background
        UIView.animate(withDuration: 0.5, delay: 1.0, options: .beginFromCurrentState, animations: {
            self.infoLabel!.alpha = 1.0
            self.infoLabel!.text = "☁️ prefetching next image..."
        })
    }
    
    
    func hidePrefetchHUD(){
        // display prefetch status, but wait a bit in the background
        UIView.animate(withDuration: 0.5, delay: 1.7, options: .beginFromCurrentState, animations: {
            self.infoLabel!.alpha = 0.0
        })
    }
    
    
    
    // loads the full HQ image in the background
    // regardless of the current browsing direction
    func prefetchNextImage(){
        

        showPrefetchHUD()
        
        // get the next prefetch image
        var prefetchPosition = indexPosition + 1
        
        
        // do we have images at all?
        // and not only one image? otherwise the prefetching is useless
        if(phAssetResult.count > 1){
            // did we reach the end of the list, then switch to the start
            if(prefetchPosition == phAssetResult.count){
                prefetchPosition = 0
            }
    
            let prefetchAsset: PHAsset = getAsset(atIndex: prefetchPosition)
            

            
            // first load the main image synchronously for a quick result
            // and the load the image again asyncly and abort loading when the user swipes etc.
            imageAsyncRequestID =  self.loadImage(asset: prefetchAsset, isSynchronous: false, resultHandler: { imageData, dataUTI, orientation, infoArray in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                
                // general information about the loaded asset
                // print("Load information \(infoArray)")
                // HERE WE GET THE IMAGE
                
                
                
                if(infoArray != nil){
                    
                    // did we really get the requested image and not an old callback?
                    if(infoArray!["PHImageResultRequestIDKey"] != nil){
                        if(infoArray!["PHImageResultRequestIDKey"] as! PHImageRequestID != self.imageAsyncRequestID!){
                            // print("old image request \(infoArray!["PHImageResultRequestIDKey"]) ignoring result")
                            // no HUD update needed here, since this is not the image we want to display
                            return
                        }
                        
                    }
                    
                    
                    
                    if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                        if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                            print("============    DEGRADED: Setting no image     ============")
                            
                            // loading ended or aborted
                            DetailController.isLoadingProgress = false
                            self.hidePrefetchHUD()
                            return
                            
                        }
                        
                    }
                }
                
                if(imageData == nil){
                    print("missing HQ image data")
                    // loading ended or aborted
                    DetailController.isLoadingProgress = false
                    self.hidePrefetchHUD()
                    return
                }
                
                
                
                // HERE NO FALLBACK IMAGE, since we already loaded the fallback as lowres before usually
                if let image = UIImage(data: imageData!){
                    // print("HQ callback returned with an image \(image.size)")
                    
                    // update the metadata display since we have now loaded
                    // the original image - might take more time to parse
                    self.updateMetadataHUD(imageData: imageData!)
                    
                    
                    // CHECK FOR SIZE IF IT FAILED PERHAPS
                    if(image.size.width < 400 && image.size.height < 300 ){
                        self.hidePrefetchHUD()
                        return
                    } else {
                        self.infoLabel!.text = "✅ prefetched next image"
                        self.hidePrefetchHUD()
                    }
                    
                    
     
                    self.hidePrefetchHUD()
                    
                    
                } else {
                    // loading ended or aborted
        
                    self.hidePrefetchHUD()
        
                    print("error creating HQ image from data")
                }
                
            })
            
            
            
            
            
        }
        
        
        
    }
    
    
    

    
    func showLoadingHUD(){
        infoLabel!.text = loadingText
        
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: .beginFromCurrentState, animations: {
            self.infoLabel!.alpha = 1.0
        })
    }
    
    func hideLoadingHUD(){
        // before removing wait a while to display the current loaded status
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .beginFromCurrentState, animations: {
            self.infoLabel!.alpha = 0.0
        })
        
    }

    
    
    func showMetadataHUD(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .beginFromCurrentState, animations: {
            self.metadataHUD!.alpha = 1.0
            
            self.metadataHUD.frame = CGRect(x:  1475  , y: 20 , width:425 ,  height: 147)
            
            
        })
    }
    
    
    
    
    func hideMetadataHUD(){
        UIView.animate(withDuration: 0.4, delay: 0, options: .beginFromCurrentState, animations: {
            self.metadataHUD!.alpha = 0.0
                        self.metadataHUD.frame = CGRect(x:  1920  , y: 20 , width:100 ,  height: 50)
        })
    }
    
    
    
    // updates the metadata display based on the
    // provided imagedata
    func updateMetadataHUD(imageData: Data){
        // METADATA DISPLAY
        
        // RESET TO EMPTY DEFAULTS
        labelSpeed.text = ""
        labelFstop.text = ""
        labelLength.text = ""
        labelISO.text = ""
        labelCamera.text = ""
        labelLens.text = ""
        
        
        
        // check if we have an facicon
        var favText = ""
        if(getAsset().isFavorite){
            favText = "❤️"
        }
        
        
        // POSITION
        labelIndex.text = "\(favText) \(indexPosition + 1 ) of \(phAssetResult.count )"
        
        
        
        // DATE
        if let date = self.getAsset().creationDate{
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .long
            formatter.timeStyle = .medium
            labelDate.text = formatter.string(from: date)
        } else {
            labelDate.text = ""
        }
        
        
        
        // EXIF METADATA

        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil){
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)! as NSDictionary;
            
           // print("getting Exif data")
           // print(imageProperties)
            
            if let exifAuxDict = imageProperties.value(forKey: "{ExifAux}") as? NSDictionary{
                

                
                
                if let lensModel = exifAuxDict.value(forKey: "LensModel") as? NSString{
                    labelLens.text = lensModel as String
                } else {
                    labelLens.text = ""
                }
   
            }
            
            
            if let exifDict = imageProperties.value(forKey: "{Exif}") as? NSDictionary{
          
                
                if let iso = exifDict.value(forKey: "ISOSpeedRatings") as! NSArray? {

                    labelISO.text = "ISO \(iso[0])"
                } else {
                    labelISO.text = ""
                }
                
                
                if let fnumber = exifDict.value(forKey: "FNumber") as! NSNumber? {
                    
                    labelFstop.text = "\(fnumber)"
                } else {
                    labelFstop.text = ""
                }
                
                if let exposure = exifDict.value(forKey: "ExposureTime") as! NSNumber? {
                    
                    labelSpeed.text = "1/\(  Int((1.0 / exposure.doubleValue)) )"
                } else {
                    labelSpeed.text = ""
                }
                
                
                if let focalLength = exifDict.value(forKey: "FocalLength") as! NSNumber?{
      
                    
                    labelLength.text = "\(focalLength)mm"
                } else {
                    labelLength.text = ""
                }
                
            }
            
            
            
            if let tiffDict = imageProperties.value(forKey: "{TIFF}") as? NSDictionary{
                
                var camera = ""
                
                if let make = tiffDict.value(forKey: "Make") as? NSString{
                    camera = make as String
                } else {
                    labelCamera.text = camera
                }
                
                
                if let model = tiffDict.value(forKey: "Model") as? NSString{
                    labelCamera.text = "\(camera) \(model as String)"
                } else {
                    labelCamera.text = ""
                }
                
            }
            
            
            // EXIF METADATA
            /*
             let imageSource = CGImageSourceCreateWithData(imageData as! CFData, nil)
             let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as NSDictionary;
             
             print(imageProperties)
             let exifDict = imageProperties.value(forKey: "{Exif}")  as! NSDictionary;
             let dateTimeOriginal = exifDict.value(forKey: "DateTimeOriginal") as! NSString;
             print ("DateTimeOriginal: \(dateTimeOriginal)");
             
             let lensMake = exifDict.value(forKey: "LensMake");
             print ("LensMake: \(lensMake)");
             */
            
            
            
            
        }
        
        
        
    }
    
    
    func hideCategoryHUD(){
        // reset category classification HUD
        // category1Label!.text = ""
        // category2Label!.text = ""
        
        

        
        
 
                    
        
        /*UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: { () -> Void in
 */
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
        self.categoryHUD.alpha = 0
            self.categoryHUD.frame = CGRect(x:  1920  , y: 175 , width:100 ,  height: 50)
            
        }, completion: {
            (ended) -> Void in
            //
        })
    }
    
    
    
    func showCategoryHUD(){
        
   //     UIView.animate(withDuration: 0.3, animations: { () -> Void in
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: { () -> Void in
            self.categoryHUD.alpha = 1
            self.categoryHUD.frame = CGRect(x:  1475  , y: 175 , width:425 ,  height: 60)
            
        }, completion: {
            (ended) -> Void in
            //
        })
    }
    
    
    func loadMainImage(){
        
        hideCategoryHUD()
        
        
        
        // update the position in the sourrounding parent controller
        // inform our collection view about the new position
        if let controller = presentingSmartController{
            controller.lastIndexPosition = indexPosition
        } else {
            print("ERROR: could not synchronize position due to missing controller")
        }
        
        // print(IndexPath(row:  self.indexPosition, section: 0))
        // last selection tracking does not really
        // work. skip this part for now
        // collectionViewController?.collectionView?.selectItem(at: IndexPath(row:  self.indexPosition, section: 0), animated: true, scrollPosition: .top )
        
        

        // check and display the map overlay when needed
        showMap()
        
        // indicate we are loading an image
        self.infoLabel!.alpha = 0.0
        
        hideLoadingHUD()
        

        
        
        // first load the main image synchronously for a quick result
        // and the load the image again asyncly and abort loading when the user swipes etc.
        // discardable result
        _ = self.loadImage(asset: self.getAsset(), isSynchronous: true, resultHandler: { imageData, dataUTI, orientation, infoArray in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                
                // general information about the loaded asset
                // print("Load information \(infoArray)")
                // HERE WE GET THE IMAGE
                
         
                
                if(infoArray != nil){
                    if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                        if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                            print("============    DEGRADED: Setting no image     ============")
                            
                            // loading ended or aborted


                            return
                         
                        }
                        
                    }
                }
                
                if(imageData == nil){
                    print("normal image was NIL: fallback image used")
                    self.imageView.image = UIImage(named: "taxcloud_hd")
                    return
                }
            
                
                if let image = UIImage(data: imageData!){
                    // hide the preview image before setting the real image...
                    self.imageView2.alpha = 0
                    
                    self.imageView.image = image
                    self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
                    // loading ended or aborted

                    // update the metadata hud based on the image
                    self.updateMetadataHUD(imageData: imageData!)
                    
                    
                    
                } else {
                    // loading ended or aborted
                    print("error creating image from data")
                }
                
            })
            
            
        
        
        // load the additional HQ image if wanted
        if(SettingsController.isHighresDownloadEnabled() == true){
            loadHQImage()
        }
        
        
    }
    
    func loadHQImage(){
        ///////////////////////////////  ASYNC LOADING SECOND TASK
        DetailController.isLoadingProgress = true
        showLoadingHUD()
        
        
        // first load the main image synchronously for a quick result
        // and the load the image again asyncly and abort loading when the user swipes etc.
        imageAsyncRequestID =  self.loadImage(asset: self.getAsset(), isSynchronous: false, resultHandler: { imageData, dataUTI, orientation, infoArray in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            
            
            // general information about the loaded asset
            // print("Load information \(infoArray)")
            // HERE WE GET THE IMAGE
            
            
            
            if(infoArray != nil){
                
                // did we really get the requested image and not an old callback?
                if(infoArray!["PHImageResultRequestIDKey"] != nil){
                    if(infoArray!["PHImageResultRequestIDKey"] as! PHImageRequestID != self.imageAsyncRequestID!){
                        // print("old image request \(infoArray!["PHImageResultRequestIDKey"]) ignoring result")
                        // no HUD update needed here, since this is not the image we want to display
                        return
                    }
                    
                }
                
                
                
                if(infoArray!["PHImageResultIsDegradedKey"] != nil){
                    if(infoArray!["PHImageResultIsDegradedKey"] as! Bool == true){
                        print("============    DEGRADED: Setting no image     ============")
                        
                        // loading ended or aborted
                        DetailController.isLoadingProgress = false
                        self.hideLoadingHUD()
                        
                        return
                        
                    }
                    
                }
            }
            
            if(imageData == nil){
                print("missing HQ image data")
                // loading ended or aborted
                DetailController.isLoadingProgress = false
                self.hideLoadingHUD()
                return
            }
            
            
            
            // HERE NO FALLBACK IMAGE, since we already loaded the fallback as lowres before usually
            if let image = UIImage(data: imageData!){
               // print("HQ callback returned with an image \(image.size)")
                
                // update the metadata display since we have now loaded
                // the original image - might take more time to parse
                self.updateMetadataHUD(imageData: imageData!)
                

                // CHECK FOR SIZE IF IT FAILED PERHAPS
                if(image.size.width < 400 && image.size.height < 300 ){
                    self.infoLabel!.text = "⚠️️ lowres \(image.size)"
                    return
                } else {
                    self.infoLabel!.text = "✅ highres \(image.size)"
                    
                }
    
            
                // IGNORE FOR PERFORMANCE this time
                // update the metadata hud based on the image
                //self.updateMetadataHUD(imageData: imageData!)
                
                
                // hide the preview image before setting the real image...
                self.imageView2.alpha = 0
                
                self.imageView.image = image
                self.imageView.center = CGPoint(x: self.initialCenterX, y: self.initialCenterY)
                // loading ended or aborted
                DetailController.isLoadingProgress = false
                self.hideLoadingHUD()
                
                // now fire up the image detection and background loading
                // for the next asset
                self.detectImage()
                
                self.prefetchNextImage()
                

                
            } else {
                // loading ended or aborted
                DetailController.isLoadingProgress = false
                self.hideLoadingHUD()
                print("error creating HQ image from data")
            }
            
        })
        
        
        // print("Request ID high async load: \(imageAsyncRequestID)")

    }
    
    
    func detectImage() {
    
        // display nothing when the HUD is disabled
        
        if(HUDMode == .none){
            return
        }
        
        guard let model = try? VNCoreMLModel(for: GoogLeNetPlaces().model) else {
            
        //guard let model = try? VNCoreMLModel(for: VGG16().model) else {
            fatalError("Failed to load model")
        }
        
        // Create a vision request
        
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
            }
            
            
            
            
            // Update the Main UI Thread with our result
            DispatchQueue.main.async { [weak self] in
                
                
                // show only results if the confidence is higher than 5%
                if(Int(topResult.confidence * 100) > 20){
                    self!.showCategoryHUD()
                    
                    self!.category1Label!.text = "🔖 \(topResult.identifier)  (\(Int(topResult.confidence * 100))%)"
                    
                    
                    self!.category2Label!.text = ""
                    
                    // currently disabled for better UXP only showing first category
                    /*
                    if(results.count > 2){
                        let secondResult = results[1]
                        
                        // and show only second result on high confidence
                        if(Int(secondResult.confidence * 100) > 10){
                            self!.category2Label!.text = "\(secondResult.identifier)  (\(Int(secondResult.confidence * 100))%)"
                        }
                        

                    }
                     */
                }

                
            }
        }
        
        // set the image to analyze
        guard let ciImage = CIImage(image: self.imageView.image!)
            else { fatalError("Cant create CIImage from UIImage") }
        
        // Run the classifier
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
                
            } catch {
                print(error)
            }
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // safe the base center information for the image 
        // to center display
        initialCenterX = imageView.center.x
        initialCenterY = imageView.center.y
        
        
        
        // add tap gesture for a click to get next photo
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clicked) )
        
   //     let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector?)
       // let tapRecognizer = UITapGestureRecognizer(target: self, action: clicked(recognizer: nil) )
        //   tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)];
        view.addGestureRecognizer(tapRecognizer)
        
        
        // add tap gesture for a playpause button
        /*
        let playRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButton(_:)) )
        playRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        view.addGestureRecognizer(playRecognizer)
        */
        
        
        // add pan gesture recognizer
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(panned) )
        view.addGestureRecognizer(panRec)
        
        
        // load the main image: default slot or given position from the 
        // controller
        loadMainImage()

        // dynamics for swipe gestures
        addDynamics()
        
        
        // doubletap recognizer
        let dtapr = UITapGestureRecognizer(target: self, action: #selector(doubleClickPlay) )
        dtapr.allowedPressTypes = [ NSNumber(value: UIPressType.playPause.rawValue)]
        dtapr.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(dtapr)
        
        
        // Register for long presses
        // to switch HUD modes: EXIF and MAP
        let longRg = UILongPressGestureRecognizer(target: self, action: #selector(longPressPlay(_:)) )
        longRg.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        view.addGestureRecognizer(longRg)
        

        
        // Register for long presses MENU
        // to switch general modes and actions
        let longMenu = UILongPressGestureRecognizer(target: self, action: #selector(longPressSelect(_:)) )
        longMenu.allowedPressTypes = [NSNumber(value: UIPressType.select.rawValue)];
        view.addGestureRecognizer(longMenu)
        

        
 
        
        // hide the metadata HUD by default
        metadataHUD.alpha = 0
        
        // hide the map also by default
        mapView.alpha = 0
        
        // map styling when the view appeared
        
        mapView.layer.masksToBounds = false;
        mapView.layer.shadowOffset = CGSize(width:15, height:15);
        mapView.layer.shadowRadius = 5;
        mapView.layer.shadowOpacity = 0.2;
        mapView.layer.cornerRadius = 16
        

        
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        

        
        // remove all gesture recognizers from map ;) whops
        // but save the data before (!)
        
        mapRecoginzerArray = mapView.gestureRecognizers
        
        
        // init the menu escape recognizer
        menuRecognizer = UITapGestureRecognizer(target: self, action: #selector(menuPress(_:)) )
        menuRecognizer!.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)];

        
        
        

 
        
        /*
        for rec in mapRecoginzerArray!{
                    mapView.removeGestureRecognizer(rec)
        }
 */
        
        // enable the HUB by default according to settings!
        if(SettingsController.isMapOverlayEnabled()){
            toggleHUDState()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // get the real image coordinates of the embedded image
    // the UIimage in the UIimage View is fit via the aspect ratio
    // and may render differently on the per pixel screens
    func calculateScreenImageBounds() -> CGRect {
        
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
