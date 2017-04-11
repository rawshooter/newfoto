//
//  DateAssets.swift
//  newfoto
//
//  Created by Thomas Alexnat on 11.04.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

// helper class
// for displaying sections of PHAsset objects
// in a UICollection view
class DateAssets: NSObject {

    
    var date = Date()
    
    var assetArray: [PHAsset] = []
    
    
    init(initDate: Date) {
       date = initDate
    
    }
    
    
}
