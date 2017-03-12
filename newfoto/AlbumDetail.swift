//
//  AlbumDetail.swift
//  newfoto
//
//  Created by Thomas Alexnat on 12.03.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

// generic class to handle albums for sorting, etc.
class AlbumDetail: NSObject {

    // this title serves as default value
    // when the localized version has no value
    let fallbackTitle = "(title missing)"
    
    var localizedTitle: String = ""
    
    // date of the album, fallback is the current timestamp
    var latestAssetDate: Date = Date()
    
    // might be null if nothing is available
    var estimatedAssetCount: Int = 0
    var assetCol: PHAssetCollection
    
    // precalculate needed information
    // for display and faster access
    init(assetCollection: PHAssetCollection) {
        // perform some initialization here
        assetCol = assetCollection
        
        // set the number of photos available in this album
        estimatedAssetCount = assetCol.estimatedAssetCount
        
        // set the title of the album if available
        // provide a fallback value
        if let title = assetCol.localizedTitle {
            localizedTitle = title
        } else {
            localizedTitle = fallbackTitle
        }
        
        
        
        // get the date of the latest
        // photo to sort the albums
        // later by date
        // if no date is available the album should be
        // sorted out
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // fetch the collection
        let assets = PHAsset.fetchAssets(in: assetCol, options: allPhotosOptions)
        
        // check if there are available photos in the subalbum
        if assets.count > 0 {
            let asset = assets.object(at: 0)
            if let date = asset.creationDate{
                latestAssetDate = date
            }
        }
            
        
    }
    
    func getDateOfLastestAsset() -> Date?{
        return latestAssetDate
    }
    
    
    func getTitle() -> String{
        return localizedTitle
    }
}
