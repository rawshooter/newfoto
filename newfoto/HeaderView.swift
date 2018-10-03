//
//  HeaderView.swift
//  newfoto
//
//  Created by Thomas Alexnat on 09.04.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
    
    // label for date and information display
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var mapButton: UIButton!
    @IBAction func mapButtonAction(_ sender: Any) {
    }
    @IBOutlet weak var infoStack: UIStackView!
    
    
}
