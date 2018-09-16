//
//  AssetMetadata.swift
//  newfoto
//
//  Created by Thomas Alexnat on 16.09.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

/*
 contains all the details for displaying
 assets on a map, including GPS geo coordinates
 */
class AssetMetadata: NSObject {

    let phAsset: PHAsset
    
    var geoLocation: CLLocationCoordinate2D?
    var thumbnail: UIImage?
    
    
    init(phAsset: PHAsset) {
        self.phAsset = phAsset
    }
    
}
