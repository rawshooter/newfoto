//
//  AlbumCell.swift
//  newfoto
//
//  Created by Thomas Alexnat on 04.12.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var glossyView: UIImageView!

    @IBOutlet weak var glossyParentView: UIView!
    
     
    // unique information for the cell when setting the
    // image asyncronously the call back handler can check the validity of the
    // indexpath
    var indexPath: IndexPath? = nil
    
    
}

