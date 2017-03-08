//
//  CollectionViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 06.11.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

fileprivate let imageManager = PHImageManager()
fileprivate var thumbnailSize: CGSize!

class CollectionViewController: UICollectionViewController {

    let reuseIdentifier = "OverviewCell"
    
    // get all photos
    var allPhotos: PHFetchResult<PHAsset>!

    // The cells zoom when focused.
    var focusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.15, y: 1.15)
    }
    
    // The cells zoom when focused.
    var unFocusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    
    // check when the controller is shown if we have access to the photo library
    override func viewDidAppear(_ animated: Bool) {
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // do we have access to the photo library? if not just display a info disclaimer view controller
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status != PHAuthorizationStatus.authorized) {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "DisclaimerController") as? DisclaimerViewController{
                
                // show it on the highest level as a modal view
               // present(controller, animated: false, completion: nil)
                
                // show it on the highest level as a modal view
                //show(controller, sender: self)
                
                view.window?.rootViewController = controller
                
                
                // print("name of the presented view controller \(presentedViewController?.restorationIdentifier)")
                // print("Controller is shown")
                return
            }
        }
        
        // it seems have have access, lets get the photos
        if (status == PHAuthorizationStatus.authorized) {
            print("Access granted to library")
            // Create a PHFetchResult object for each section in the table view.
            // load only the photos if not set from outside
            if(allPhotos == nil){
                print("loading photos")
                let allPhotosOptions = PHFetchOptions()
                // ONLY fotostream is ascending - the rest is configurable
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                collectionView?.reloadData()
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        

        // set the number of available photos
        //tabBarItem.badgeValue = "\(allPhotos.count)"
    }
    
    
    
    
    
    //func collectionView(collectionView: UICollectionView,
     //                   didUpdateFocusInContext context: UICollectionViewFocusUpdateContext,
       //                 withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        

    // ZOOM
    
    
    

    
    override  func collectionView(_ collectionView: UICollectionView,
                                  didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                                  with coordinator: UIFocusAnimationCoordinator) {
        
        coordinator.addCoordinatedAnimations({ [unowned self] in
            
            // 3D Rotation
            
            let m34 = CGFloat(1.0 / -1250)
            let minMaxAngle = 7.0
            let angle = CGFloat(minMaxAngle * M_PI / 180.0)
            
            
            var baseTransform = CATransform3DIdentity
            baseTransform.m34 = m34
            
            
            // X rotate
            var rotateYmin = baseTransform
            rotateYmin = CATransform3DRotate(rotateYmin,  angle, 0.0, 1.0, 0.0);
            
            var rotateYmax = baseTransform
            rotateYmax = CATransform3DRotate(rotateYmax, -1 * angle, 0.0, 1.0, 0.0);
            
            
            //.rotation.x
            let yRotationMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: .tiltAlongHorizontalAxis)
            
            //   yRotationMotionEffect.minimumRelativeValue = -0.5
            //   yRotationMotionEffect.maximumRelativeValue = 0.5
            
            
            yRotationMotionEffect.minimumRelativeValue = NSValue(caTransform3D: rotateYmin)
            yRotationMotionEffect.maximumRelativeValue = NSValue(caTransform3D: rotateYmax)
            
            // Y rotate
            
            var rotateXmin = baseTransform
            rotateXmin = CATransform3DRotate(rotateXmin, -1 * angle, 1.0, 0.0, 0.0);
            
            var rotateXmax = baseTransform
            rotateXmax = CATransform3DRotate(rotateXmax,  angle, 1.0, 0.0, 0.0);
            
            
            //.rotation.x
            let xRotationMotionEffect = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: .tiltAlongVerticalAxis)
            
            //   yRotationMotionEffect.minimumRelativeValue = -0.5
            //   yRotationMotionEffect.maximumRelativeValue = 0.5
            
            
            xRotationMotionEffect.minimumRelativeValue = NSValue(caTransform3D: rotateXmin)
            xRotationMotionEffect.maximumRelativeValue = NSValue(caTransform3D: rotateXmax)
            
            
            
            //////////////
            
            
            let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            verticalMotionEffect.minimumRelativeValue = -20
            verticalMotionEffect.maximumRelativeValue = 20
            
            let horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            horizontalMotionEffect.minimumRelativeValue = -20
            horizontalMotionEffect.maximumRelativeValue = 20
            
            
            // alpha blacken effect
            
            let darkenEffect = UIInterpolatingMotionEffect(keyPath: "layer.alpha", type: .tiltAlongVerticalAxis)
            darkenEffect.minimumRelativeValue = 0.0
            darkenEffect.maximumRelativeValue = 1
            
            
            // motion effect for glossy layer
            
            let verticalGlossyEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            verticalGlossyEffect.minimumRelativeValue = -400
            verticalGlossyEffect.maximumRelativeValue = 400
            
            let horizontalGlossyEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
            horizontalGlossyEffect.minimumRelativeValue = -400
            horizontalGlossyEffect.maximumRelativeValue = 400
            
            let motionGlossyGroup = UIMotionEffectGroup()
            motionGlossyGroup.motionEffects = [horizontalGlossyEffect, verticalGlossyEffect]
            
            let motionEffectGroup = UIMotionEffectGroup()
            
            motionEffectGroup.motionEffects = [yRotationMotionEffect, xRotationMotionEffect, horizontalMotionEffect, verticalMotionEffect]
            
            
            if let
                nextIndexPath = context.nextFocusedIndexPath,
                let focusCell = collectionView.cellForItem(at: nextIndexPath) as? OverviewCell
            {
                
                print("focus")
                
                
                // bringt to front
                self.view.bringSubview(toFront: focusCell)
                
                
                
                
                
                // add the motion effects to the cell
                focusCell.addMotionEffect(motionEffectGroup)
                
                
                // reduce the brightness
                focusCell.glossyView?.layer.opacity = 0.3
                
                // give the glossy image an effect
                focusCell.glossyView?.addMotionEffect(motionGlossyGroup)
                
                // remove color and light when the trackpad moves from the image
                focusCell.image?.addMotionEffect(darkenEffect)
                
                
                
                
                focusCell.layer.cornerRadius = 16
                focusCell.layer.masksToBounds = true
                
                // also set the image view some nice corner radius
                focusCell.image?.layer.cornerRadius = 16
                focusCell.image?.layer.masksToBounds = true
                
                // white border
                //focusCell.layer.borderColor = UIColor.white.cgColor
                //focusCell.layer.borderWidth = 5
                focusCell.layer.masksToBounds = false;
                focusCell.layer.shadowOffset = CGSize(width:15, height:15);
                focusCell.layer.shadowRadius = 5;
                focusCell.layer.shadowOpacity = 0.2;
                
                
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .beginFromCurrentState,
                               animations: { () -> Void in
                                focusCell.transform = self.focusedTransform
                                //                     nameLabel.transform = CGAffineTransformIdentity
                },
                               completion: nil)
                
            }
            
            if let
                previousIndexPath = context.previouslyFocusedIndexPath,
                let focusCell = collectionView.cellForItem(at: previousIndexPath) as? OverviewCell
            {
                print("unfocus")
                // and remove all effects from unfocused cell
                for effect in focusCell.motionEffects{
                    focusCell.removeMotionEffect(effect)
                }
                
                // remove effect from glossy cell
                for effects in focusCell.glossyView!.motionEffects{
                    focusCell.glossyView!.removeMotionEffect(effects)
                }
                
                // make the image invisible
                focusCell.glossyView!.layer.opacity = 0
                
                
                
                
                self.view.sendSubview(toBack: focusCell)
                
                
                focusCell.layer.cornerRadius = 16
                focusCell.layer.masksToBounds = true
                focusCell.layer.shadowOffset = CGSize(width:0, height:0);
                focusCell.layer.shadowRadius = 0;
                
                
                
                //focusCell.layer.borderColor = UIColor.white.cgColor
                //focusCell.layer.borderWidth = 0
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0,
                               options: .beginFromCurrentState,
                               animations: { () -> Void in
                                focusCell.transform = self.unFocusedTransform
                                //                     nameLabel.transform = CGAffineTransformIdentity
                },
                               completion: nil)
                
            }
            
            
            
            
            }, completion: nil)
    }

    /*
    
    override  func collectionView(_ collectionView: UICollectionView,
                                  didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                                  with coordinator: UIFocusAnimationCoordinator) {
        
        
        if let
            nextIndexPath = context.nextFocusedIndexPath,
            let focusCell = collectionView.cellForItem(at: nextIndexPath) as? OverviewCell
        {

            print("focus")
            focusCell.setFocused(focused: true, withAnimationCoordinator: coordinator)
        }
        
        if let
            previousIndexPath = context.previouslyFocusedIndexPath,
            let focusCell = collectionView.cellForItem(at: previousIndexPath) as? OverviewCell
        {
                        print("unfocus")
            focusCell.setFocused(focused: false, withAnimationCoordinator: coordinator)
        }
        

        
        
    }
    
      */

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
      
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("triggering collectionview numbers of items in section")
        if(allPhotos == nil){
            return 0
        }
        
        return allPhotos.count
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = allPhotos.object(at: indexPath.item)
        
        
        
        
        // Dequeue a GridViewCell.


        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? OverviewCell
                  else { fatalError("unexpected cell in collection view") }
        
        
        // use the indexpath as an unique identifier
        // to check for asny loading if this is the right cell
        cell.indexPath = indexPath
        
        
        
        // intially we don´t want to have a glossy cell
        cell.glossyView!.layer.opacity = 0
        
        
        
        
        
        // and remove all effects from unfocused cell
        // to remove hicups of fast scrolling
        for effect in cell.motionEffects{
            cell.removeMotionEffect(effect)
        }
        
        // white border
        //cell.layer.borderColor = UIColor.white.cgColor
        //cell.layer.borderWidth = 0
        
        self.view.sendSubview(toBack: cell)
        
        // configure rounded cornders
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        
        cell.glossyParentView?.layer.cornerRadius = 16
        cell.glossyParentView?.layer.masksToBounds = true
        
        
        
        thumbnailSize = CGSize(width: 380, height: 280)
        
        
        // Request an image for the asset from the PHCachingImageManager.
      //  cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset
            if(cell.indexPath == indexPath){
                
                // HERE WE SET THE IMAGE
                cell.image?.image = image
                
            } else {
                // INFO: Scrolloing was to fast for setting this image. Maybe this cell has alreay a newer image
            }
            // if not let the image unchanged
            
            
            //cell.label?.text = "\(asset.creationDate)"
            
            
        })
      //  cell.backgroundColor = UIColor.lightGray

        // nice cell radius
        cell.image?.layer.cornerRadius = 16
        cell.image?.layer.masksToBounds = true
        
        
        // image label
        let date = asset.creationDate
        

        
        //let myLocale = Locale(identifier: "de_DE")
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let dateStr = formatter.string(from: date!)
        
        
        cell.label?.text = "\(dateStr)"
        //cell.label?.text = "\(dateStr) Uhr"
        
        return cell
        
    }

  
    
    
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    

    
    // check selection and push to detail view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath){
        print("selected element \(didSelectItemAt.item)")
        
        
        // no need to load a new storyboard. it already exists
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "DetailController") as? DetailController{
            print("Controller found")
            
            //self.present(controller, animated: true, completion: nil)
            // set the asset to display in the detail controller
            //controller.asset =  allPhotos.object(at: didSelectItemAt.item) as PHAsset
            controller.indexPosition = didSelectItemAt.item
            controller.phAssetResult = allPhotos
            
            
        
            self.show(controller, sender: self)
            
            print("name of the presented view controller \(presentedViewController?.restorationIdentifier)")
            
        }
        
        
        
    }
    
    


}
