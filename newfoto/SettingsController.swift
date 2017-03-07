//
//  SettingsController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 20.11.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

class SettingsController: UIViewController {

  
    let sortOrderText = "🖼  Sort order of photos in albums: "
    let zoomFactorText = "🔍  Zoom factor: "
    let mapOverlayText = "🗺  GPS metadata display: "
    
    let zoomFactorDefaultsKey = "ZOOM_FACTOR"
    let mapConfigOverlayDefaultsKey = "MAP_OVERLAY"
    let sortOrderDefaultsKey = "SORT_ORDER"
    
    let zoomFactors = ["1.5": 1.5, "2.0": 2.0, "2.5": 2.5, "3.0": 3.0]
    let zoomFactorInitial = "2.5"
    
    let sortOrderAscending = "ASCENDING"
    let sortOrderDescending = "DECENDING"

    
    let mapEnabled = "ENABLED"
    let mapDisabled = "DISABLED"
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func sortOrderAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        // zoomfactor default and NIL coalescing as fallback default value
        let sortOrderDefault = defaults.object(forKey: sortOrderDefaultsKey) as? String ?? sortOrderDescending
        
        
        if(sortOrderDefault == sortOrderAscending){
            defaults.set(sortOrderDescending, forKey: sortOrderDefaultsKey)
            sortOrderButton.setTitle(sortOrderText + "Newest First", for: .normal)
            
        } else {
            defaults.set(sortOrderAscending, forKey: sortOrderDefaultsKey)
            sortOrderButton.setTitle(sortOrderText + "Oldest First", for: .normal)
            
        }
    }
    
    
    @IBAction func mapOverlayAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        // zoomfactor default and NIL coalescing as fallback default value
        let mapOverlayDefault = defaults.object(forKey: mapConfigOverlayDefaultsKey) as? String ?? mapEnabled
        
        
        if(mapOverlayDefault == mapEnabled){
            defaults.set(mapDisabled, forKey: mapConfigOverlayDefaultsKey)
            mapOverlayButton.setTitle(mapOverlayText + mapDisabled, for: .normal)
        } else {
            defaults.set(mapEnabled, forKey: mapConfigOverlayDefaultsKey)
            mapOverlayButton.setTitle(mapOverlayText + mapEnabled, for: .normal)
        }
        
    }

    
    // iterate of the existing zoom factor values, starting with the current set user default
    @IBAction func zoomFactorAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        // zoomfactor default and NIL coalescing as fallback default value
        let zoomFactorDefault = defaults.object(forKey: zoomFactorDefaultsKey) as? String ?? zoomFactorInitial
        
 
        // get a sorted array of the collection keys
        let sortedKeys = zoomFactors.keys.sorted(by: <  )
        
        // get the index position of the found key in the array
        if let indexForDefault = sortedKeys.index(of: zoomFactorDefault){
            
            // get next value of the zoomfactors or start at the beginning of the keys
            // when reached the end
            if(indexForDefault < sortedKeys.count - 1){
                let nextKeyForDefault = sortedKeys[indexForDefault + 1]
                
                defaults.set(nextKeyForDefault, forKey: zoomFactorDefaultsKey)
                zoomFactorButton.setTitle(zoomFactorText + nextKeyForDefault + "x", for: .normal)
                
            } else {
                let nextKeyForDefault = sortedKeys[0]
                defaults.set(nextKeyForDefault, forKey: zoomFactorDefaultsKey)
                zoomFactorButton.setTitle(zoomFactorText + nextKeyForDefault + "x", for: .normal)
            }
        } else {
            // stored defaults value was not found in our defaults array
            // due to renaming or other issues
            // fall back to a real default value
            defaults.set(sortedKeys[0], forKey: zoomFactorDefaultsKey)
            zoomFactorButton.setTitle(zoomFactorText + sortedKeys[0] + "x", for: .normal)
            
        }
    }
    
    @IBOutlet weak var mapOverlayButton: UIButton!
    @IBOutlet weak var sortOrderButton: UIButton!
    @IBOutlet weak var zoomFactorButton: UIButton!
    
    
    // The cells zoom when focused.
    var focusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.3, y: 1.3)
    }
    
    // The cells zoom when focused.
    var unFocusedTransform: CGAffineTransform {
        return CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    
    func zoomIn(){
        UIView.animate(withDuration: 40,
                       delay: 1,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations: { () -> Void in self.imageView.transform = self.focusedTransform}
            ,
                       completion: { (completed: Bool) -> Void in  self.zoomOut() }
        )
    }
    
    func zoomOut(){
        
        
        UIView.animate(withDuration: 40,
                       delay: 1,
                       options: [.beginFromCurrentState, .curveLinear],
                       animations: { () -> Void in self.imageView.transform = self.unFocusedTransform}
            ,
                       completion: { (completed: Bool) -> Void in  self.zoomIn() }
        )
        
        
    }

    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the defaults
        let defaults = UserDefaults.standard
        
        // update the current button state
        let zoomFactorDefault = defaults.object(forKey: zoomFactorDefaultsKey) as? String ?? zoomFactorInitial
        print("zoomfactorDefault: \(zoomFactorDefault)")
        zoomFactorButton.setTitle(zoomFactorText + zoomFactorDefault + "x", for: .normal)
        
        
        
        let sortOrderDefault = defaults.object(forKey: sortOrderDefaultsKey) as? String ?? sortOrderDescending
            print("sortOrderDefault: \(sortOrderDefault)")
        
        if(sortOrderDefault == sortOrderAscending){
            sortOrderButton.setTitle(sortOrderText + "Oldest First", for: .normal)
        }
        
        if(sortOrderDefault == sortOrderDescending){
            sortOrderButton.setTitle(sortOrderText + "Newest First", for: .normal)
        }
        
        
        
        // zoomfactor default and NIL coalescing as fallback default value
        let mapOverlayDefault = defaults.object(forKey: mapConfigOverlayDefaultsKey) as? String ?? mapEnabled
        
                print("mapOverlayDefault: \(mapOverlayDefault)")
        if(mapOverlayDefault == mapEnabled){
            mapOverlayButton.setTitle(mapOverlayText + mapEnabled, for: .normal)
            
        }
        
        if(mapOverlayDefault == mapDisabled){
            mapOverlayButton.setTitle(mapOverlayText + mapDisabled, for: .normal)
        }
        
        
    }
    
    

    
    
    
    // check when the controller is shown if we have access to the photo library
    override func viewDidAppear(_ animated: Bool) {
        
        

        
        
        // start animations
        zoomIn()
    }
    
    
    
    /*
    // Display the current photos count in the UI on a label
    // will use the main thread for updating the UI
    func updatePhotosCount(){
        var allPhotos: PHFetchResult<PHAsset>!
        
        // Create a PHFetchResult object for each section in the table view.
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        // set the number of available photos
        
        print("Update photo count: #\(allPhotos.count) photos. Setting label...")
        
        // update the ui via the main thread
        DispatchQueue.main.async {
            self.imageLabel.text = "\(allPhotos.count) photos"
            self.imageLabel.setNeedsDisplay()
        }
        
        
        print("...label set.")
        
    }

 */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // add photos from the tax sample gallery for usage on tvos simulator
    // to have real world example
    /*
    @IBAction func addGalleryAction(_ sender: UIButton) {

        
        // iterate over all images an add them
        for imageName in imageNames{
            
            
            if let image: UIImage = UIImage(named: imageName){
                
                // Add it to the photo library. with escaping closure (self.xyz)
                PHPhotoLibrary.shared().performChanges({
                    // Just add the image
                    print("PHAssetChangeRequest Handler adding image asset")
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                    
                    
                    
                }, completionHandler: {success, error in
                    
                    if(success){
                        print("success adding image to library. calling updatePhotosCound()")
                        self.updatePhotosCount()
                    } else {
                        print("error creating asset: \(error)")
                    }
                    
                })
            }

 
        }
        
        
        }
 */
    
   
    /*
    @IBAction func addSamplesAction(_ sender: UIButton) {
        print("add samples action triggered")
        
        
        // get access to the photo library
        // by editing the Info.plist file with the setting
        // Privacy NSPhotoLibraryUsageDescription / Privacy Prefix
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        if(status == PHAuthorizationStatus.authorized){
            print("Access granted")
            
            addSamplePhoto()
            
        } else {
            print("No access granted")
            
            PHPhotoLibrary.requestAuthorization() {status in
                switch status {
                case .authorized:
                    self.addSamplePhoto()
                    break
                // as above
                case .denied, .restricted:
                    print("Access to PhotoLibrary denied")
                    break
                // as above
                case .notDetermined:
                    print("Access to PhotoLibrary not determined")
                    break
                    // won't happen but still
                }
            }
            
        }
        
        
    }
    */
    
    
    /*
    
    func addImageToLibrary(image: UIImage) {
        // Add it to the photo library. with escaping closure (self.xyz)
        PHPhotoLibrary.shared().performChanges({
            // Just add the image
            print("PHAssetChangeRequest Handler adding image asset")
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            
      

        }, completionHandler: {success, error in
            
            if(success){
                print("success adding image to library. calling updatePhotosCound()")
                self.updatePhotosCount()
            } else {
                print("error creating asset: \(error)")
            }
            
        })
    }
    
    
    // add random sample photo to library
    // will crash then access to photo library is not granted
    func addSamplePhoto(){
        
        var allPhotos: PHFetchResult<PHAsset>!
        
        // Create a PHFetchResult object for each section in the table view.
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        // set the number of available photos
        print("Number of Photos before adding: \(allPhotos.count)")
        

                    // Create a dummy image of a random solid color and random orientation.
                    let ssize =  CGSize(width: 1200, height: 400)
                    let rrenderer = UIGraphicsImageRenderer(size: ssize)
                    let iimage = rrenderer.image { context in
                        UIColor(hue: CGFloat(arc4random_uniform(100))/100,
                                saturation: CGFloat(arc4random_uniform(100))/100, brightness: 1, alpha: 1).setFill()
                        context.fill(context.format.bounds)
                    }
                    
                    let myimage: UIImage = iimage
                    

                    
                    addImageToLibrary(image: myimage)
        
        }

    */
}
