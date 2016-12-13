//
//  CollectionViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 06.11.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

fileprivate let imageManager = PHCachingImageManager()
fileprivate var thumbnailSize: CGSize!

class CollectionViewController: UICollectionViewController {

    let reuseIdentifier = "OverviewCell"
    
    // get all photos
    var allPhotos: PHFetchResult<PHAsset>!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        
        
        // Create a PHFetchResult object for each section in the table view.
        // load only the photos if not set from outside
        if(allPhotos == nil){
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        }
        
        // set the number of available photos
        tabBarItem.badgeValue = "\(allPhotos.count)"
    }
    
    
    
    
    
    //func collectionView(collectionView: UICollectionView,
     //                   didUpdateFocusInContext context: UICollectionViewFocusUpdateContext,
       //                 withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        

    // ZOOM
    
    
    

    
    
    
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
    
       

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
      
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        
        
        // set abstract loading icon
        // this image is set and the abstract thumbnail imageloading mechanics 
        // can work in the background
        cell.image?.image = UIImage(named: "ic_image_white_48pt")
        
        /*guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OverviewCell.self), for: indexPath) as? OverviewCell
         else { fatalError("unexpected cell in collection view") }
        
*/
        //print("Cell found \(cell)")

        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: (cellSize.width) * scale, height: (cellSize.height) * scale)
        print("thumbnail size: \(thumbnailSize)")
        
        // Request an image for the asset from the PHCachingImageManager.
      //  cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset
            if(cell.indexPath == indexPath){
                
                // HERE WE SET THE IMAGE
                cell.image?.image = image
                
            } else {
                print ("INFO: Scrolloing was to fast for setting this image. Maybe this cell has alreay a newer image  ------------------------------------------------")
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
        
        
        let myLocale = Locale(identifier: "de_DE")
        
        let formatter = DateFormatter()
        formatter.locale = myLocale
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        let dateStr = formatter.string(from: date!)
        
        
        cell.label?.text = "\(dateStr)"
        
        
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
