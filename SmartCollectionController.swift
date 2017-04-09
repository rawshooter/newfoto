//
//  SmartCollectionController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 09.04.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

fileprivate let imageManager = PHImageManager()
fileprivate var thumbnailSize: CGSize =   CGSize(width: 380, height: 280)

import Photos

// this class displays the photo stream in segments
// and other phasset collections
class SmartCollectionController: UICollectionViewController {

    // phfetch result of the current photos
    var fetchResult: PHFetchResult<PHAsset>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("smart view loaded")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            if(fetchResult == nil){
                print("loading photostream")
                let allPhotosOptions = PHFetchOptions()
                // ONLY fotostream is ascending - the rest is configurable
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
                
                collectionView?.reloadData()
                
            }
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


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("items")
        if let result = fetchResult{
            print(result.count)
            return result.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        // get the requestet asset at the position
        // check if the can obtain the image
        if let asset = fetchResult?.object(at: indexPath.item){
            
            print("asset")
            // Dequeue cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SmartCell {
                print("cell")
                
                // use the indexpath as an unique identifier
                // to check for asny loading if this is the right cell
                cell.indexPath = indexPath
                
                
                
                
                
                // Request an image for the asset from the PHCachingImageManager.
                //  cell.representedAssetIdentifier = asset.localIdentifier
                imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                    
                    
                    
                    
                    // The cell may have been recycled by the time this handler gets called;
                    // set the cell's thumbnail image only if it's still showing the same asset
                    if(cell.indexPath == indexPath){
                        
                        
                        if(image==nil){
                            print("NIL image: fallback loaded")
                            cell.imageView?.image = UIImage(named: "taxcloud_small")
                        } else {
                            // HERE WE SET THE IMAGE
                            cell.imageView?.image = image
                        }
                        
                        
                    } else {
                        // INFO: Scrolloing was to fast for setting this image. Maybe this cell has alreay a newer image
                    }
                    // if not let the image unchanged
                    
                    
                    //cell.label?.text = "\(asset.creationDate)"
                    
                    
                })
                
                
                return cell
                
                
            }
            
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        
        return cell
        
        
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
