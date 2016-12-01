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

    @IBOutlet weak var imageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updatePhotosCount()

    }
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TODO: FIX THIS
    @IBAction func addGalleryAction(_ sender: UIButton) {
        let filemanager = FileManager.default
        let path = Bundle.main.resourcePath!
        
        
        
        var fileList: [String]
        
        do{
            try
                fileList = filemanager.contentsOfDirectory(atPath: path)
            
            
            
            for item in fileList {
                      print(item)
                if item.hasSuffix("jpg") {
                    // this is a picture to load!
                    // print(path + "/" + item)
                    print(item)
                   // pictures.append(item)
                }
            }
        } catch {
            print("error happened \(error)")
        }
        
    }
    
    
    
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


}
