//
//  AboutViewController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 03.09.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override var preferredFocusedView: UIView? {
        return textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.isSelectable = true
        textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue)]
    }
    

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
