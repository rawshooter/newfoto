//
//  DetailControllerViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 16.11.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

class DetailController: UIViewController, UIGestureRecognizerDelegate {

    // Asset to be displayed - can be NIL when called
    var asset: PHAsset?
    
    let zoomFactor = 2.0
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

    
    var intialCenterX: CGFloat = 0
    var intialCenterY: CGFloat = 0
    
    var baseCenterX: CGFloat = 0
    var baseCenterY: CGFloat = 0
    
    @IBOutlet weak var imageView: UIImageView!
    
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
    let maxTouchTime = 0.5
    let maxPauseIntervalForTupleTap = 0.5
    
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
    
    
    func switchZoomMode(){
        
        let imageFrame = imageView.frame
        
        print("ImageView size: \(imageFrame)")
        print("Image size \(imageView.image?.size)")
        
        print("ImageView center: \(imageView.center)")
        
        // zoom in or zoom out
        if(isZoomMode){
            isZoomMode = false
            
            
            // zoom out
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .beginFromCurrentState,
                           animations: { () -> Void in
                            self.imageView.transform = self.normalTransform
                            self.imageView.center = CGPoint(x: self.intialCenterX, y: self.intialCenterY)
            }, completion: nil)
            
            
        } else {
            isZoomMode = true
            
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
        

 
        if (touch.view?.isDescendant(of: self.view))!{
            return false
        }
        return true
    }
    
    

    
    // we have the signature as a panrecognizer
    func panned(_ recognizer: UIPanGestureRecognizer ){
        
            
        //print(recognizer.translation(in: view))
        
        //print(recognizer.velocity(in:  view))
        
        
        // do no image movement since we´re not in zoom mode
        if(!isZoomMode){
            print("ignoring gestures - recognizer could also be removed")
            return
        }
        
        
        /*
        var myFrame: CGRect = CGRect(x: 0,y: 0, width: 400, height: 500)
 */

        
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
            
            
            
            
            
            /*
             image.frame.width = recognizer.translation(in: view).x
             
             image.frame.width = recognizer.translation(in: view).y
             
             */
            
            
            // center x
            var x = baseCenterX + trackpadX;
            
            
            
            // check the boundaries
            // add some frame butter
         /*
            if(x < -10){
                x = -10
            }
            
            if(x>1930){
                x = 1930
            }
           */
            
            x = getSafeXCenter(x: x)
            //print("current x \(x)")
            
            
            var y = baseCenterY + trackpadY;
            
            /*
             let x = imageView.center.x + trackpadX;
             let y = imageView.center.y + trackpadY;
             */
            
            //y = getSafeYCenter(y: y)
            /*
            if(y<0){
                y=0
            }
            
            if(y>1024){
                y=1024
            }
            */
            y = getSafeYCenter(y: y)
            // print("current y \(y)")
            
            //imageView.frame = myFrame
            
          
            
            // this was replaced by the animation ;)
            //imageView.center = CGPoint(x: x, y: y)
            
           // self.imageView.center = CGPoint(x: x, y: y)
           // -----------------
            
            UIView.animate(withDuration: 0.05,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: CGFloat(10),
                         //  options: .beginFromCurrentState,
                           options: [],
                           animations: { () -> Void in
                                self.imageView.center = CGPoint(x: x, y: y)
                            
                            },
                           completion: nil)
            
            
        }
 
          //  -----------------------------
        
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
            
            if(velY != 0){
                velY = velY / 10.0
            }
            
            
            // update new base center based on velocity target
            // still need to validate the target for maximum position!
            baseCenterX = imageView.center.x + velX
            baseCenterY = imageView.center.y + velY
            
            
            
            baseCenterX = getSafeXCenter(x: baseCenterX)
            baseCenterY = getSafeYCenter(y: baseCenterY)
            
            UIView.animate(withDuration: 2.5,
                           delay: 0,
                           usingSpringWithDamping: 10,
                           initialSpringVelocity: 8,
                           options: .beginFromCurrentState,
                           animations: { () -> Void in
                            self.imageView.center = CGPoint(x: self.baseCenterX, y: self.baseCenterY)
                            
            },
                           completion: nil)
            

        
                    print("End Coordiantes (\(intialCenterX), \(intialCenterY))")
            
              //  imageView.center = CGPoint(x: intialCenterX, y: intialCenterY)
            

            
        
        }
 
            
            
 
    }
    
    
    
    //check the bounds based on the zoom factor
    
    func getSafeXCenter(x: CGFloat) -> CGFloat {
        //print("Image size \(imageView.image?.size)")
    
        var newX = x;
        
        // could crash...
        //let imageWidth = imageView.image!.size.width
        let imageWidth = imageView.bounds.width
        
        
        let min: CGFloat
        let max: CGFloat
        
        // scaled image is smaller than screensize
        if( imageWidth*CGFloat(zoomFactor) <=  CGFloat(screenWidth) ){
            min = imageWidth*CGFloat(zoomFactor) / 2
            max = CGFloat(screenWidth) - imageWidth*CGFloat(zoomFactor) / 2
        // scaled image is larger than screensize
        } else {
            min = CGFloat(screenWidth) - imageWidth*CGFloat(zoomFactor) / 2
            max = imageWidth*CGFloat(zoomFactor) / 2
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
        let imageHeight = imageView.bounds.height
        
        let min: CGFloat
        let max: CGFloat
        
        // scaled image is smaller than screensize
        if( imageHeight*CGFloat(zoomFactor) <=  CGFloat(screenHeight) ){
            min = imageHeight*CGFloat(zoomFactor) / 2
            max = CGFloat(screenHeight) - imageHeight*CGFloat(zoomFactor) / 2
            // scaled image is larger than screensize
        } else {
            min = CGFloat(screenHeight) - imageHeight*CGFloat(zoomFactor) / 2
            max = imageHeight*CGFloat(zoomFactor) / 2
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
    
    
    

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        intialCenterX = imageView.center.x
        intialCenterY = imageView.center.y
        
        print("Initial Coordiantes (\(intialCenterX), \(intialCenterY))")
        
       /*
        let longRec = UILongPressGestureRecognizer(target: self, action: #selector(tapped) )
        longRec.delegate = self
        view.addGestureRecognizer(longRec)
        */
   /*
        let swipeRec = UILongPressGestureRecognizer(target: self, action: #selector(tapped) )
        swipeRec.delegate = self
        view.addGestureRecognizer(swipeRec)
     */
        
        
        
        
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(panned) )
        //panRec.delegate = self
        view.addGestureRecognizer(panRec)
        
        
/*
        // enable double tapping
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped) )
 
        
        tapRecognizer.numberOfTapsRequired = 1
 */
       // tapRecognizer.allowedPressTypes = [NSNumber()]
        
        
        //tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue)];
        
        //tapRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue)]
        
      /*
        tapRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue)]
        
        
        tapRecognizer.delegate = self
        // let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        view.addGestureRecognizer(tapRecognizer)
        */
        
        
        // load the asset image for the detail view
        
        
        let imageManager = PHCachingImageManager()
        var imageSize: CGSize
        
        let imageFrame = imageView.frame
        
        
        print("size width: \(imageFrame.width) height: \(imageFrame.height)")
        let scale = UIScreen.main.scale
        

        
        imageSize = CGSize(width: (imageFrame.width) * scale, height: (imageFrame.height) * scale)
        
        
        if let myAsset = asset{
            // Request an image for the asset from the PHCachingImageManager.
            //  cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: myAsset, targetSize: imageSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                // HERE WE GET THE IMAGE
                self.imageView.image = image
                print("detail image was loaded")
            })
        } else {
            print("missing asset for detail view")
        }

        
        
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
