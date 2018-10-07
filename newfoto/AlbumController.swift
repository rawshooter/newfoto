//
//  AlbumController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 04.12.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "AlbumCell"

fileprivate let imageManager = PHCachingImageManager()
//fileprivate let thumbnailSize =  CGSize(width: 616, height: 616)
fileprivate let thumbnailSize =  CGSize(width: 308, height: 308)
//fileprivate let thumbnailSize =  CGSize(width: 512, height: 512)




// adds the prefetiching protocoll implementation to look forward
//class AlbumController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
class AlbumController: UICollectionViewController {

    // indicator shows if the albums are currently loaded
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    // status of the loaded albums
    var isAlbumCollectionLoaded = false
    
    // contains all the albums, intially an empty array
    var sortedAlbumArray: [AlbumDetail] = []
    
    // The cells zoom when focused.
    var focusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.15, y: 1.15)
    }
    
    // The cells zoom when focused.
    var unFocusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    
    // collection of albums can be NIL
   // var colAlbums: PHFetchResult<PHAssetCollection>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        activityIndicator.center = CGPoint(x: 960, y: 512)
        
        activityIndicator.startAnimating()
        
        
        // let button = UIButton(frame: CGRect(x: 100, y: 200, width: 300, height: 100))
        // button.setTitle("My Button", for: .normal)
        
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        
        

        

        // Do any additional setup after loading the view.
      
        // getAlbums()
        
        // set this instance as the prefetch datasource
        // can be set via storyboard, but lets check it really
        // collectionView?.isPrefetchingEnabled = true
       // collectionView?.prefetchDataSource =  self
        
        
        
        // handle long press to open dedicated map view
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        self.view.addGestureRecognizer(lpgr)

    }
    
    
    /**
     handle the long press on a select album
     and display then the map view
     */
    @objc func handleLongPress(gesture : UILongPressGestureRecognizer!) {
        // react on the first timeout of the longpress
        // and not other events to avoid duplicate loading and ignore
        // when we have no album collections
        if(gesture.state != .began || sortedAlbumArray.isEmpty) {
            return
        }
        
        let p = gesture.location(in: self.collectionView)
        
        if let indexPath = self.collectionView?.indexPathForItem(at: p) {
            // instantiate the map view
            if let controller = storyboard?.instantiateViewController(withIdentifier: "MapController") as? MapController{
                let album    = sortedAlbumArray[indexPath.row]
                // give the controller all the needed assets
                controller.album = album
                
                self.show(controller, sender: self)
            }
        } else {
            // nothing found
            print("couldn't find index path")
        }
    }
    
    
    
    
    // updated configuration 
    override func viewDidAppear(_ animated: Bool) {

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
        
        
        if(!isAlbumCollectionLoaded){
            getAlbums()
            collectionView?.reloadData()
            activityIndicator.stopAnimating()
            isAlbumCollectionLoaded = true
            
            if let tabController = (tabBarController as? TabBarController){
                
               tabController.focusOnceAlbumController()
            }
            
        }
        
        
        if(SettingsController.hasAlbumListOrderChangedDefault){
            // set to normal since we have already received the event
            SettingsController.hasAlbumListOrderChangedDefault = false
            
            
            // just resort
            sortAlbums()
            collectionView?.reloadData()
            
        }
    
    }
    
    
    
    // temporarly removed due to acceptable performance using standard prefetching ;)
    /*
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
     /*
        print("========================= PREFETCH CALLED ")
        for indexPath in indexPaths {
            // calculate/update/collect some data
            print("Prefetch Rows: \(indexPath.row)")
        }*/
    }
    
    // temporarly removed due to acceptable performance using standard prefetching ;)
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
       /* for indexPath in indexPaths {
                    print("========================= PREFETCH CANCELLED ")
            // calculate/update/collect some data
            print("Prefetch Rows: \(indexPath.row)")
        }
    */
 
 }
 */
    
    // retrieve all photo collections from the current user
    // populate the array of the albums for better sorting and prefetching
    // for better performance
    func getAlbums(){
        
        
        // for ph asset collection there are no sort options available from the current tvos and ios API
        // get all albums
        let colAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
        

        
        // fill our helper albumArray structure
        for index in 0..<colAlbums.count{
            sortedAlbumArray.append(AlbumDetail(assetCollection: colAlbums.object(at: index) as PHAssetCollection))
        }
        
        // just sort
        sortAlbums()

    }
    
    
    
    // SORT the album array
    func sortAlbums(){
        // order album array by settings
        let sortOrder = SettingsController.getAlbumListOrder()
        
        switch sortOrder{
        case "Newest First":
            sortedAlbumArray.sort(by: {$0.latestAssetDate > $1.latestAssetDate })
        case "Oldest First":
            sortedAlbumArray.sort(by: {$0.latestAssetDate < $1.latestAssetDate })
        case "A - Z":
            sortedAlbumArray.sort(by: {$0.localizedTitle.uppercased() < $1.localizedTitle.uppercased() })
        case "Z - A":
            sortedAlbumArray.sort(by: {$0.localizedTitle.uppercased() > $1.localizedTitle.uppercased() })
        default:
            sortedAlbumArray.sort(by: {$0.localizedTitle.uppercased() < $1.localizedTitle.uppercased() })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    // return the number of albums we have
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // return 0
        
     //   return colAlbums!.count
        return sortedAlbumArray.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get the custom album cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCell
        
        
        // intially we don´t want to have a glossy cell since it is currently NOT in focus
        cell.glossyView!.layer.opacity = 0
        
        // get the album
        // get the asset collection of the selected album
        //let assetCollection: PHAssetCollection = colAlbums!.object(at: indexPath.row)
        
        // get the album of the sorted array
        let assetCollection: PHAssetCollection = sortedAlbumArray[indexPath.row].assetCol
        
        cell.titleLabel.text = "\(assetCollection.localizedTitle!)"
        
        
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
        // cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        
        // cell.glossyParentView?.layer.cornerRadius = 16
        cell.glossyParentView?.layer.masksToBounds = true
        
        
        
        
        
        // and now get the first image as a display
        // add sorting prefix for assets
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !SettingsController.isSortOrderDescending())]
        
        // fetch the collection
        let assets = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
        // print("Number of Photos in selected collection: \(assets.count)")
        
        // check if there are available photos in the subalbum
        if assets.count > 0 {
            
            let asset = assets.object(at: 0)
            
            // and try to load the first image from the collection
            

            
            // Determine the size of the thumbnails to request from the PHCachingImageManager
            // TODO: WRONG SIZE? The thumbnail is not the cell size but a smaller portion of the image
            // might lead to aliasing
            /*
            let scale = UIScreen.main.scale
            let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            thumbnailSize = CGSize(width: (cellSize.width) * scale, height: (cellSize.height) * scale)
*/
            
            
            //TODO: Set an intermediate loading image while the thumbnail IS loading??
            
            
            // Request an image for the asset from the PHCachingImageManager.
            //  cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                if(image==nil){
                    print("NIL image: fallback loaded")
                    cell.imageView?.image = UIImage(named: "taxcloud_small")
                } else {
                    // HERE WE SET THE IMAGE
                    cell.imageView?.image = image
                }
                

                
            })


        } else {
            print("empty album: settings fallback image")
            cell.imageView?.image = UIImage(named: "taxcloud_small")
        }
        
        
        // TODO: WARNING Rasterization bakes all the layers 
        // and cannot be moved individually
   //     cell.layer.shouldRasterize = true;
   //     cell.layer.rasterizationScale = UIScreen.main.scale;
        
        return cell
    }
    

    
    
    
    
    
    
    
    // check selection and push to detail view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath){
       // print("selected element \(didSelectItemAt.item)")
        
        
        
        
        // instantiate the collection view controller to display the album list
        //  if let controller = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController{
        if let controller = storyboard?.instantiateViewController(withIdentifier: "SmartCollectionController") as? SmartCollectionController{
                
            

            // no cast to PHAssetCollection needed
        //    let assetCollection =  colAlbums!.object(at: didSelectItemAt.item)
            let albumDetails    = sortedAlbumArray[didSelectItemAt.item]
            let assetCollection =   albumDetails.assetCol
            
            
   
            // add sorting prefix for assets
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !SettingsController.isSortOrderDescending())]
   
            // fetch the collection
            let assets = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
            // print("Number of Photos in selected collection: \(assets.count)")
            
            // give the controller all the needed assets
            controller.allPhotos = assets
            
            controller.albumName = assetCollection.localizedTitle ?? ""
            
            controller.album = albumDetails
            
            // controller.asset =  colAlbums.object(at: didSelectItemAt.item) as PHAssetCollection
            
            
            
            self.show(controller, sender: self)
            
         //   print("name of the presented view controller \(presentedViewController?.restorationIdentifier)")
            
        }
        
        
        
    }
    
    
    
    override  func collectionView(_ collectionView: UICollectionView,
                                  didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                                  with coordinator: UIFocusAnimationCoordinator) {
        
        coordinator.addCoordinatedAnimations({ [unowned self] in
            
            // 3D Rotation
            
            let m34 = CGFloat(1.0 / -1250)
            let minMaxAngle = 6.0
            let angle = CGFloat(minMaxAngle * .pi / 180.0)
            
            
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
                let focusCell = collectionView.cellForItem(at: nextIndexPath) as? AlbumCell
            {
                
                print("focus")
                
                
                // bringt to front
                self.view.bringSubview(toFront: focusCell)
                
                
    
                // add the motion effects to the cell
                focusCell.addMotionEffect(motionEffectGroup)
                
                
                // reduce the brightness
                focusCell.glossyView?.layer.opacity = 0.4
                
                // give the glossy image an effect
                focusCell.glossyView?.addMotionEffect(motionGlossyGroup)
                
                
                

                
                // focusCell.layer.cornerRadius = 16
                focusCell.layer.masksToBounds = true

                // also set the image view some nice corner radius
                //focusCell.imageView?.layer.cornerRadius = 16
                focusCell.imageView?.layer.masksToBounds = true

                // white border
                //focusCell.layer.borderColor = UIColor.white.cgColor
                //focusCell.layer.borderWidth = 5
                focusCell.layer.masksToBounds = false;
                focusCell.layer.shadowOffset = CGSize(width:10, height:10);
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
                let focusCell = collectionView.cellForItem(at: previousIndexPath) as? AlbumCell
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
                
                
                // focusCell.layer.cornerRadius = 16
                focusCell.layer.masksToBounds = true
                focusCell.layer.shadowOffset = CGSize(width:0, height:0);
                focusCell.layer.shadowRadius = 0;
                
                
                
                //focusCell.layer.borderColor = UIColor.white.cgColor
                //focusCell.layer.borderWidth = 0
                UIView.animate(withDuration: 0.4,
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
    
    
    
}
