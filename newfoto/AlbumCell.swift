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
    
    @IBOutlet weak var subTitleLabel: UILabel!

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var glossyView: UIImageView!


    
         
     var centerGlossyX : CGFloat {
        get {
            return centerGlossyX
        }
        set (aNewValue) {
            //I've contrived some condition on which this property can be set
            //(prevents same value being set)
            if (aNewValue != centerGlossyX) {
                centerGlossyX = aNewValue * 2
               
            }
             glossyView.center.x = centerGlossyX
        }
    }
    
    var centerGlossyY : CGFloat {
        get {
            return centerGlossyY
        }
        set (aNewValue) {
            //I've contrived some condition on which this property can be set
            //(prevents same value being set)
            if (aNewValue != centerGlossyY) {
                centerGlossyY = aNewValue * 2
                print("new y \(centerGlossyY)")
            }
            
             glossyView.center.y = centerGlossyY
            
        }
    }
    

    
}

