//
//  ImageAnnotation.swift
//  newfoto
//
//  Created by Thomas Alexnat on 16.09.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit
import MapKit
import Photos

/*
 
 using this for my photos as an annotation
 data model to display later with MKAnnotationView image
 
 */
class ImageAnnotation: MKPlacemark {
  
    
    var image: UIImage?
    var phAsset: PHAsset?
    
}
