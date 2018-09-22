//
//  mapThumbnailCell.swift
//  newfoto
//
//  Created by Thomas Alexnat on 22.09.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit

class mapThumbnailCell: UICollectionViewCell {
  
    
    @IBOutlet weak var imageView: UIImageView!
    
    // unique information for the cell when setting the
        // image asyncronously the call back handler can check the validity of the
        // indexpath
        var indexPath: IndexPath? = nil
        
    
}

