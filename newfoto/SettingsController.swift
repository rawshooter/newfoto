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
    
    
    let imageNames: [String] = ["IMG_0383.jpg",
        "IMG_0417.jpg",       "IMG_0479.jpg",
        "IMG_0541.jpg",        "IMG_0557.jpg",
        "IMG_0689.jpg",        "IMG_0725.jpg",
        "IMG_1057.jpg",        "IMG_1087.jpg",
        "IMG_1129.jpg",       "IMG_1132.jpg",
        "IMG_1389.jpg",        "IMG_1543.jpg",
        "IMG_1683.jpg",        "IMG_1684.jpg",
        "IMG_1691.jpg",       "IMG_1704.jpg",
        "IMG_2219.jpg",        "IMG_2343.jpg",
        "IMG_2387.jpg",        "IMG_2642.jpg",
        "IMG_2851.jpg",        "IMG_3009.jpg",
        "IMG_3015.jpg",        "IMG_3083.jpg",
        "IMG_3084.jpg",        "IMG_3285.jpg",
        "IMG_3286.jpg",        "IMG_3852.jpg",
        "IMG_7481.jpg",       "IMG_7555.jpg",
        "IMG_7560.jpg",        "IMG_7632.jpg",
        "IMG_7907.jpg",        "IMG_8008.jpg",
        "IMG_8074.jpg",        "IMG_8078.jpg",
        "IMG_8114.jpg",        "IMG_8240.jpg",
        "IMG_8306.jpg",        "IMG_8314.jpg",
        "IMG_8337.jpg",        "IMG_8605.jpg",
        "IMG_8635.jpg",        "IMG_8647.jpg",
        "IMG_8702.jpg",        "IMG_8928.jpg",
        "IMG_9253.jpg",        "IMG_9268.jpg",
        "P1020627-2.jpg",        "P1020724.jpg",
        "P1030125.jpg",        "P1040050.jpg",
        "P1040067.jpg",        "P1040103.jpg",
        "P1040108.jpg",        "P1040139.jpg",
        "P1040185.jpg",        "P1040204.jpg",
        "P1040210.jpg",        "P1040216.jpg",
        "P1040290.jpg",        "P1040303.jpg",
        "P1040486.jpg",        "P1040621.jpg",
        "P1040626.jpg",        "P1040632.jpg",
        "P1040641.jpg",        "P1040680.jpg",
        "P1040688.jpg",        "P1040824.jpg",
        "P1040858.jpg",        "P1040869.jpg",
        "P1040913.jpg",        "P1040915.jpg",
        "P1040918.jpg",        "P1040939.jpg",
        "P1040941.jpg",        "P1040943.jpg",
        "P1040948.jpg",        "P1040957.jpg",
        "_MG_5323.jpg",        "_MG_5357.jpg",
        "_MG_5363.jpg"
    ]
    
    
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
    
    
    // add photos from the tax sample gallery for usage on tvos simulator
    // to have real world example
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
