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
fileprivate let thumbnailSize =  CGSize(width: 380, height: 280)


// adds the prefetiching protocoll implementation to look forward
class AlbumController: UICollectionViewController, UICollectionViewDataSourcePrefetching {
    
    
    // The cells zoom when focused.
    var focusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.15, y: 1.15)
    }
    
    // The cells zoom when focused.
    var unFocusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    
    // collection of albums can be NIL
    var colAlbums: PHFetchResult<PHAssetCollection>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // we do not need to register since we have a storyboard that loaded all the stuff
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
        getAlbums()
        
        // set this instance as the prefetch datasource
        // can be set via storyboard, but lets check it really
        // collectionView?.isPrefetchingEnabled = true
        collectionView?.prefetchDataSource =  self

    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("========================= PREFETCH CALLED ")
        for indexPath in indexPaths {
            // calculate/update/collect some data
            print("Prefetch Rows: \(indexPath.row)")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
                    print("========================= PREFETCH CANCELLED ")
            // calculate/update/collect some data
            print("Prefetch Rows: \(indexPath.row)")
        }
    }
    
    
    // retrieve all photo collections from the current user
    func getAlbums(){
        
        
        
        // get some collections: there are differnt types of collection lists
        
        
        
        
        
        // get smart folders: smartFolder
        
        // SmartFolder: Events, People
        /*
         let colFolders: PHFetchResult<PHCollectionList> = PHCollectionList.fetchCollectionLists(with: PHCollectionListType.smartFolder,
         subtype: PHCollectionListSubtype.any, options: nil)
         */
        
        
        // empty?
        /*
         let colFolders: PHFetchResult<PHCollection> = PHCollectionList.fetchTopLevelUserCollections(with: nil)
         
         */
        
        
        //------  SMART ALBUMS: camera roll, panoramas, etc//
        /*
         let colSmartAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: nil)
         */
        
        
        
        //------  SMART ALBUMS: camera roll, panoramas, etc//
        
        
        
        
        
        // for ph asset collection there are no sort options available from the current tvos and ios API
        colAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
        
        
        
        
        // EMTPY?
        /*
         let colFolders: PHFetchResult<PHCollectionList> = PHCollectionList.fetchCollectionLists(with: PHCollectionListType.folder,
         subtype: PHCollectionListSubtype.any, options: nil)
         
         */
        
        
        
        
        
        for index in 0..<colAlbums!.count{
            
            colAlbums!.object(at: index)
            print("----------------")
            print("collection #\(index) is '\(colAlbums!.object(at: index) )'")
            print("----------------")
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
        
        return colAlbums!.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get the custom album cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCell
        
        
        // intially we don´t want to have a glossy cell since it is currently NOT in focus
        cell.glossyView!.layer.opacity = 0
        
        // get the album
        // get the asset collection of the selected album
        let assetCollection: PHAssetCollection = colAlbums!.object(at: indexPath.row)
        
        
        cell.subTitleLabel.text = "\(assetCollection.estimatedAssetCount)"
        
        
        
        //cell.subTitleLabel.text = "\(assetCollection.estimatedAssetCount) photos \(assetCollection.localizedLocationNames)"
        
        //        cell.subTitleLabel.text = "\(assetCollection.estimatedAssetCount) Bilder vom \(assetCollection.startDate) bis
        //(assetCollection.endDate)"
        
        
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
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        
        
        cell.glossyParentView?.layer.cornerRadius = 16
        cell.glossyParentView?.layer.masksToBounds = true
        
        
        
        
        
        // and now get the first image as a display
        // add sorting prefix for assets
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !SettingsController.isSortOrderDescending())]
        
        // fetch the collection
        let assets = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
        print("Number of Photos in selected collection: \(assets.count)")
        
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
                
                if(image != nil){
                    
                    // HERE WE SET THE IMAGE
                    cell.imageView?.image = image
                } else {
                    print ("error loading thumbail for album overview")
                }

                
            })

            
            
            
            
            
            
            
            
            
            
            
        }
        
        
        // TODO: WARNING Rasterization bakes all the layers 
        // and cannot be moved individually
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.main.scale;
        
        return cell
    }
    

    
    
    
    // check selection and push to detail view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath){
        print("selected element \(didSelectItemAt.item)")
        
        
        
        
        // instantiate the collection view controller to display the album list
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController{
            
            

            // no cast to PHAssetCollection needed
            let assetCollection =  colAlbums!.object(at: didSelectItemAt.item)
            
            
   
            // add sorting prefix for assets
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: !SettingsController.isSortOrderDescending())]
   
            // fetch the collection
            let assets = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
            print("Number of Photos in selected collection: \(assets.count)")
            
            // give the controller all the needed assets
            controller.allPhotos = assets
            
            
            // controller.asset =  colAlbums.object(at: didSelectItemAt.item) as PHAssetCollection
            
            
            
            self.show(controller, sender: self)
            
            print("name of the presented view controller \(presentedViewController?.restorationIdentifier)")
            
        }
        
        
        
    }
    
    
    
    override  func collectionView(_ collectionView: UICollectionView,
                                  didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                                  with coordinator: UIFocusAnimationCoordinator) {
        
        coordinator.addCoordinatedAnimations({ [unowned self] in
            
            // 3D Rotation
            
            let m34 = CGFloat(1.0 / -1250)
            let minMaxAngle = 6.0
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
                
                
                

                
                focusCell.layer.cornerRadius = 16
                focusCell.layer.masksToBounds = true

                // also set the image view some nice corner radius
                focusCell.imageView?.layer.cornerRadius = 16
                focusCell.imageView?.layer.masksToBounds = true

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
    
    
    
}
