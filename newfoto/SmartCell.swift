//
//  SmartCell.swift
//  newfoto
//
//  Created by Thomas Alexnat on 09.04.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit

class SmartCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // unique information for the cell when setting the
    // image asyncronously the call back handler can check the validity of the
    // indexpath
    var indexPath: IndexPath? = nil
    
    
}
