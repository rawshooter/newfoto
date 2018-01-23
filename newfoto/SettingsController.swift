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

  
    let albumListOrderText = "🗄  Ordering of Albums: "
    let sortOrderText = "🖼  Ordering of Photos: "
    let groupText = "📅  Group Photos by Date: "
    let zoomFactorText = "🔍  Zoom Factor: "
    let mapOverlayText = "🗺  GPS, EXIF & Info Display: "
    let horizonText = "⚖️  Horizon Autoadjust: "
    
    
    
    static let zoomFactorDefaultsKey = "ZOOM_FACTOR"
    static let mapConfigOverlayDefaultsKey = "MAP_OVERLAY"
    static let sortOrderDefaultsKey = "SORT_ORDER"
    static let albumListOrderDefaultsKey = "ALBUM_ORDER"
    static let groupByDateDefaultsKey = "GROUP_BY_DATE"
    static let horizonDefaultsKey = "HORIZON"
    
    // have been changed made in the confige while runtime?
    static var hasAlbumListOrderChangedDefault = false
    
    static let albumListOrder = ["A - Z", "Z - A", "Newest First", "Oldest First"]
    static let albumListOrderInitial = "Newest First"
    
    static let zoomFactors = ["1.5": 1.5, "2.0": 2.0, "2.5": 2.5, "3.0": 3.0, "3.5": 3.5, "4.0": 4.0]
    static let zoomFactorInitial = "3.0"
    
    static let sortOrderAscending = "ASCENDING"
    static let sortOrderDescending = "DECENDING"

    static let groupByDateEnabled = "ENABLED"
    static let groupByDateDisabled = "DISABLED"

    static let horizonEnabled = "ENABLED"
    static let horizonDisabled = "DISABLED"
    
    static let mapEnabled = "ENABLED"
    static let mapDisabled = "DISABLED"
    
    
    
    @IBAction func actionHorizon(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        
        if(SettingsController.isHorizonEnabled()){
            defaults.set(SettingsController.horizonDisabled, forKey: SettingsController.horizonDefaultsKey)
            horizonButton.setTitle(horizonText + SettingsController.horizonDisabled, for: .normal)
        } else {
            defaults.set(SettingsController.horizonEnabled, forKey: SettingsController.horizonDefaultsKey)
            horizonButton.setTitle(horizonText + SettingsController.horizonEnabled, for: .normal)
        }
        
        
    }
    
    @IBAction func actionHD(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "HDViewController") as? HDViewController{
            self.show(controller, sender: self)
        }
    }
    
    @IBAction func actionUHD(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "UHDViewController") as? UHDViewController{
            self.show(controller, sender: self)
        }
    }
    
    @IBAction func groupByDateAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        
        if(SettingsController.isGroupByDateEnabled()){
            defaults.set(SettingsController.groupByDateDisabled, forKey: SettingsController.groupByDateDefaultsKey)
            groupByDateButton.setTitle(groupText + SettingsController.groupByDateDisabled, for: .normal)
        } else {
            defaults.set(SettingsController.groupByDateEnabled, forKey: SettingsController.groupByDateDefaultsKey)
            groupByDateButton.setTitle(groupText + SettingsController.groupByDateEnabled, for: .normal)
        }
        
    }
    
    
    
    
    @IBAction func actionLicense(_ sender: UIButton) {
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "LicenseController") as? LicenseViewController{
            print("Controller found")
            
            
            
            // controller.presentingSmartController = self
            self.show(controller, sender: self)
            
            //self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func actionAbout(_ sender: UIButton) {

        
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "AboutController") as? AboutViewController{
            print("Controller found")
            
          
            
           // controller.presentingSmartController = self
            self.show(controller, sender: self)
            
            //self.present(controller, animated: true, completion: nil)
            
        }
    }
    
    
    // return the sort order of the user default as boolean value
    // true when it is descending and false when ascending
    class func isSortOrderDescending() -> Bool{
        // get the defaults
        let defaults = UserDefaults.standard
        
        // zoomfactor default and NIL coalescing as fallback default value
        let sortOrderDefault = defaults.object(forKey: sortOrderDefaultsKey) as? String ?? sortOrderAscending
        if(sortOrderDefault == sortOrderDescending){
            //print("Sort order DESCENDING")
            return true
        } else {
            //print("Sort order ASCENDING")
            return false
        }
    }
    
    
    // return the group order by date of the user default as boolean value
    class func isGroupByDateEnabled() -> Bool{
        // get the defaults
        let defaults = UserDefaults.standard
        
        
        let groupByDateDefault = defaults.object(forKey: groupByDateDefaultsKey) as? String ?? groupByDateEnabled
        if(groupByDateDefault == groupByDateEnabled){
            return true
        } else {
            return false
        }
    }
    

    
    // return if the horizon AI detection is enabled
    class func isHorizonEnabled() -> Bool{
        // get the defaults
        let defaults = UserDefaults.standard
        
        let horizonDefault = defaults.object(forKey: horizonDefaultsKey) as? String ?? horizonEnabled
        if(horizonDefault == horizonEnabled){
            return true
        } else {
            return false
        }
    }
    
    
    
    // return the sort order of the user default as boolean value
    // true when it is descending and false when ascending
    class func isMapOverlayEnabled() -> Bool{
        // get the defaults
        let defaults = UserDefaults.standard
        
        
        let mapOverlayDefault = defaults.object(forKey: mapConfigOverlayDefaultsKey) as? String ?? mapEnabled
        if(mapOverlayDefault == mapEnabled){
            return true
        } else {
            return false
        }
    }
    
    
    
    // return the highres state
    // only for code compatibility - removed option in userinterface
    class func isHighresDownloadEnabled() -> Bool{
      return true
    }
    
    // Return the sorting method for the
    // smart albums
    class func getAlbumListOrder() -> String{
        // get the defaults
        let defaults = UserDefaults.standard

        let albumListDefault = defaults.object(forKey: SettingsController.albumListOrderDefaultsKey) as? String ?? SettingsController.albumListOrderInitial
        
        return albumListDefault
    }
    

    // return the sort order of the user default as boolean value
    // true when it is descending and false when ascending
    class func getZoomFactor() -> Double{
        // get the defaults
        let defaults = UserDefaults.standard
        

        
        // zoomfactor default and NIL coalescing as fallback default value
        let zoomFactorDefault = defaults.object(forKey: SettingsController.zoomFactorDefaultsKey) as? String ?? SettingsController.zoomFactorInitial
        
        

        if let zoomFactor = SettingsController.zoomFactors[zoomFactorDefault] {
            return zoomFactor
        } else {
             return SettingsController.zoomFactors[zoomFactorInitial]!
        }
        
        
    }
    
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func sortOrderAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        if(SettingsController.isSortOrderDescending() ){
            defaults.set(SettingsController.sortOrderAscending, forKey: SettingsController.sortOrderDefaultsKey)
            sortOrderButton.setTitle(sortOrderText + "Oldest First", for: .normal)
            // have been changed made in the confige while runtime?
            SettingsController.hasAlbumListOrderChangedDefault = true
        } else {
            defaults.set(SettingsController.sortOrderDescending, forKey: SettingsController.sortOrderDefaultsKey)
            sortOrderButton.setTitle(sortOrderText + "Newest First", for: .normal)
            // have been changed made in the confige while runtime?
            SettingsController.hasAlbumListOrderChangedDefault = true
            
        }
    }
    
    
    @IBAction func mapOverlayAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard

        
        if(SettingsController.isMapOverlayEnabled()){
            defaults.set(SettingsController.mapDisabled, forKey: SettingsController.mapConfigOverlayDefaultsKey)
            mapOverlayButton.setTitle(mapOverlayText + SettingsController.mapDisabled, for: .normal)
        } else {
            defaults.set(SettingsController.mapEnabled, forKey: SettingsController.mapConfigOverlayDefaultsKey)
            mapOverlayButton.setTitle(mapOverlayText + SettingsController.mapEnabled, for: .normal)
        }
        
    }


    @IBAction func albumListOrderAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        // default and NIL coalescing as fallback default value
        let albumListOrderDefault = defaults.object(forKey: SettingsController.albumListOrderDefaultsKey) as? String ?? SettingsController.albumListOrderInitial
        print("albumlist value: \(albumListOrderDefault)")
        
        
        // get the index position of the found key in the array
        if let indexForDefault = SettingsController.albumListOrder.index(of: albumListOrderDefault){
         
            
            
            // get next value of the zoomfactors or start at the beginning of the keys
            // when reached the end
            if(indexForDefault < SettingsController.albumListOrder.count - 1){
                let nextKeyForDefault = SettingsController.albumListOrder[indexForDefault + 1]
                
                defaults.set(nextKeyForDefault, forKey: SettingsController.albumListOrderDefaultsKey)
                albumListOrderButton.setTitle(albumListOrderText + nextKeyForDefault, for: .normal)
                        print("albumlist new value: \(nextKeyForDefault)")
                // have been changed made in the confige while runtime?
                SettingsController.hasAlbumListOrderChangedDefault = true
            } else {
                let nextKeyForDefault = SettingsController.albumListOrder[0]
                defaults.set(nextKeyForDefault, forKey: SettingsController.albumListOrderDefaultsKey)
                albumListOrderButton.setTitle(albumListOrderText + nextKeyForDefault, for: .normal)
                                        print("albumlist new value: \(nextKeyForDefault)")
                // have been changed made in the confige while runtime?
                SettingsController.hasAlbumListOrderChangedDefault = true
                
            }
        } else {
            // stored defaults value was not found in our defaults array
            // due to renaming or other issues
            // fall back to a real default value
            let value = SettingsController.albumListOrder[0]
            defaults.set(value, forKey: SettingsController.albumListOrderDefaultsKey)
            albumListOrderButton.setTitle(albumListOrderText + value, for: .normal)
                        print("albumlist new value: \(value)")
            // have been changed made in the confige while runtime?
            SettingsController.hasAlbumListOrderChangedDefault = true
            
        }
    }
    
    
    
    // iterate of the existing zoom factor values, starting with the current set user default
    @IBAction func zoomFactorAction(_ sender: UIButton) {
        // get the defaults
        let defaults = UserDefaults.standard
        
        // zoomfactor default and NIL coalescing as fallback default value
        let zoomFactorDefault = defaults.object(forKey: SettingsController.zoomFactorDefaultsKey) as? String ?? SettingsController.zoomFactorInitial
        
 
        // get a sorted array of the collection keys
        let sortedKeys = SettingsController.zoomFactors.keys.sorted(by: <  )
        
        // get the index position of the found key in the array
        if let indexForDefault = sortedKeys.index(of: zoomFactorDefault){
            
            // get next value of the zoomfactors or start at the beginning of the keys
            // when reached the end
            if(indexForDefault < sortedKeys.count - 1){
                let nextKeyForDefault = sortedKeys[indexForDefault + 1]
                
                defaults.set(nextKeyForDefault, forKey: SettingsController.zoomFactorDefaultsKey)
                zoomFactorButton.setTitle(zoomFactorText + nextKeyForDefault + "x", for: .normal)
                
            } else {
                let nextKeyForDefault = sortedKeys[0]
                defaults.set(nextKeyForDefault, forKey: SettingsController.zoomFactorDefaultsKey)
                zoomFactorButton.setTitle(zoomFactorText + nextKeyForDefault + "x", for: .normal)
            }
        } else {
            // stored defaults value was not found in our defaults array
            // due to renaming or other issues
            // fall back to a real default value
            defaults.set(sortedKeys[0], forKey: SettingsController.zoomFactorDefaultsKey)
            zoomFactorButton.setTitle(zoomFactorText + sortedKeys[0] + "x", for: .normal)
            
        }
    }
    
    @IBOutlet weak var mapOverlayButton: UIButton!
    @IBOutlet weak var sortOrderButton: UIButton!
    @IBOutlet weak var zoomFactorButton: UIButton!
    @IBOutlet weak var albumListOrderButton: UIButton!
    @IBOutlet weak var groupByDateButton: UIButton!
    @IBOutlet weak var horizonButton: UIButton!
    
    
    
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
        let zoomFactorDefault = defaults.object(forKey: SettingsController.zoomFactorDefaultsKey) as? String ?? SettingsController.zoomFactorInitial
        print("zoomfactorDefault: \(zoomFactorDefault)")
        zoomFactorButton.setTitle(zoomFactorText + zoomFactorDefault + "x", for: .normal)
        
        // update the current button state
        let albumListDefault = defaults.object(forKey: SettingsController.albumListOrderDefaultsKey) as? String ?? SettingsController.albumListOrderInitial
        print("albumListDefault: \(albumListDefault)")
        albumListOrderButton.setTitle(albumListOrderText + albumListDefault, for: .normal)
        
        
        
        let sortOrderDefault = defaults.object(forKey: SettingsController.sortOrderDefaultsKey) as? String ?? SettingsController.sortOrderAscending
            print("sortOrderDefault: \(sortOrderDefault)")
        
        if(sortOrderDefault == SettingsController.sortOrderAscending){
            sortOrderButton.setTitle(sortOrderText + "Oldest First", for: .normal)
        }
        
        if(sortOrderDefault == SettingsController.sortOrderDescending){
            sortOrderButton.setTitle(sortOrderText + "Newest First", for: .normal)
        }
        
        
        let groupByDateDefault = defaults.object(forKey: SettingsController.groupByDateDefaultsKey) as? String ?? SettingsController.groupByDateEnabled
        print("groupByDateDefault: \(groupByDateDefault)")
        
        if(groupByDateDefault == SettingsController.groupByDateEnabled){
            groupByDateButton.setTitle(groupText + SettingsController.groupByDateEnabled, for: .normal)
        }
        
        if(groupByDateDefault == SettingsController.groupByDateDisabled){
            groupByDateButton.setTitle(groupText + SettingsController.groupByDateDisabled, for: .normal)
        }
        
        
        let horizonDefault = defaults.object(forKey: SettingsController.horizonDefaultsKey) as? String ?? SettingsController.horizonEnabled
        print("horzizonDefault: \(horizonDefault)")
        
        if(horizonDefault == SettingsController.horizonEnabled){
            horizonButton.setTitle(horizonText + SettingsController.horizonEnabled, for: .normal)
        }
        
        if(horizonDefault == SettingsController.horizonDisabled){
            horizonButton.setTitle(horizonText + SettingsController.horizonDisabled, for: .normal)
        }
        
        
        
        
        // mapoverlay
        let mapOverlayDefault = defaults.object(forKey: SettingsController.mapConfigOverlayDefaultsKey) as? String ?? SettingsController.mapEnabled
        
                print("mapOverlayDefault: \(mapOverlayDefault)")
        if(mapOverlayDefault == SettingsController.mapEnabled){
            mapOverlayButton.setTitle(mapOverlayText + SettingsController.mapEnabled, for: .normal)
            
        }
        
        if(mapOverlayDefault == SettingsController.mapDisabled){
            mapOverlayButton.setTitle(mapOverlayText + SettingsController.mapDisabled, for: .normal)
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
