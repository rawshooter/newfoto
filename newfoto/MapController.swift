//
//  MapController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 15.09.18.
//  Copyright © 2018 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos
import MapKit

class MapController: UIViewController, MKMapViewDelegate {

    var album: AlbumDetail?
    
    fileprivate let thumbnailSize =  CGSize(width: 100, height: 100)
    fileprivate let imageManager = PHImageManager()
    
    // the map view to display all image positions
    @IBOutlet weak var mapView: MKMapView!
    
    // array with the identified assets containing
    // location infos
    var assetMetas: [AssetMetadata] = []
    
    // notification view to display messages
    let notification: NotificationView = NotificationView()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        /*
         - load all assets
         - parse through all assets and load the image
         - parse the image for GPS EXIF
         - setup for every image an annotvation view
         - setup cluster annotations
 
         */
        
        // add the notification view
        view.addSubview(notification)
        view.bringSubview(toFront: notification)
        
        
        // set this class as the mapview delegate controller
        // to get more options e.g. for annotations
        mapView.delegate = self
        
    }
    
    //
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("asking for annotation view for map")

        // check if we have found a
        // image annotation data model
        // and set the image as annotation
        // but it might be to big :)
        if let imageAnnotation = annotation as? ImageAnnotation{
            let annotationView = MKAnnotationView()
            
            // Request an image for the asset from the PHCachingImageManager.
            //  cell.representedAssetIdentifier = asset.localIdentifier
            // better photo fetch options
            let options: PHImageRequestOptions = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .fastFormat
            options.version = .current
            options.isSynchronous = true
            
            // disabled for the momoent
            /*
            self.imageManager.requestImage(for: imageAnnotation.phAsset!, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: options, resultHandler: { image, _ in
                if(image != nil){
                    annotationView.image = image
                }
                
            })
            */


            return nil
        }
        
        
        return nil
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        notification.showMessage(message: "Building Geo Locations")
        buildImageLibrary()
       notification.showMessage(message: "Found \(assetMetas.count) Locations")
        
        
        
        
        for assetMeta in assetMetas{
            let annotation = ImageAnnotation(coordinate: assetMeta.geoLocation!)
            annotation.phAsset = assetMeta.phAsset
            

            mapView.addAnnotation(annotation)
            
        }
        
    }

    func buildImageLibrary(){
        
        // do we really have the album set from outside?
        guard let album = album else { return }
        
        
        // get the date of the latest
        // photo to sort the albums
        // later by date
        // if no date is available the album should be
        // sorted out
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // fetch the collection
        let assets = PHAsset.fetchAssets(in: album.assetCol, options: allPhotosOptions)
        
        // iterate over all assets
        assets.enumerateObjects { (phAsset, index, stopBooleanPointer) in
            // add asset meta
            _ = self.loadImage(asset: phAsset, isSynchronous: true){ imageData, dataUTI, orientation, infoArray in
                
                guard let imageData = imageData else { return }
      
                
                // now check every image for GPS
                
                var gpsLocation: CLLocationCoordinate2D?
                
                // take a shortcut and try to obtain a location
                if(phAsset.location?.coordinate != nil){
                    gpsLocation = phAsset.location!.coordinate
                }
                
                // or via the image data
                if let location = self.getGPSCoordinates(imageData: imageData){
                    gpsLocation = location
                }
                
                if( gpsLocation != nil){
                    // oh we did get a gps coordinate
                    
                    
                    
                    let assetMeta = AssetMetadata(phAsset: phAsset)
                    //   assetMeta.thumbnail = image
                    
                    assetMeta.geoLocation = gpsLocation
                    
                    self.assetMetas.append(assetMeta)
                }
            }
 
 
        }
    }
    
    
    

    // generic function that loads an image for the requested asset
    // add the requesting asset to load and provide an handler to use the image
    // returns the PHImageRequestID to e.g. cancel the request for long running tasks when other UXP action is needed
    @discardableResult func loadImage(asset: PHAsset, isSynchronous: Bool, resultHandler: @escaping (Data?, String?, UIImageOrientation, [AnyHashable : Any]?) -> Void) -> PHImageRequestID{
        
        //let imageManager = PHCachingImageManager()
        let imageManager = PHImageManager.default()
        
        // better photo fetch options
        let options: PHImageRequestOptions = PHImageRequestOptions()
        
        // important for loading network resources and progressive handling with callback handler
        options.isNetworkAccessAllowed = true
        
        // loads one or more steps
        //options.deliveryMode = .opportunistic
        
        // only the highest quality available: only one call (!)
        // deliverymode is ignored on requestimagedata (!) method
        
        options.deliveryMode = .fastFormat
        
        // latest version of the asset
        options.version = .current
        
        // only on async the handler is being requested
        // TODO: Warning isSync FALSE produces currently unwanted errors for image loading
        options.isSynchronous = isSynchronous
        

        
        let requestID:PHImageRequestID = imageManager.requestImageData(for: asset, options: options, resultHandler: resultHandler)
        return requestID
    }
    
    
    /**
     Parses the provided images EXIF data to get more
     information about the GPS location and returns the GPS coordinates
     if available
     
     - parameter imageData: CFData image data stream e.g. from a PHAsset image request
     
     - returns:  CLLocationCoordinate2D GPS coordinates of the image or nil if unable to detct
     */
    fileprivate func getGPSCoordinates(imageData: Data) -> CLLocationCoordinate2D?{
        if let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil){
            if let newProps = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: AnyObject]  {
                
                
                var latitude: CLLocationDegrees
                var longitude: CLLocationDegrees
                
                if let gpsDic = newProps[kCGImagePropertyGPSDictionary as String] as? [String: AnyObject] {
                    guard let longitudeRaw = gpsDic[kCGImagePropertyGPSLongitude as String] as? Double else { return nil }
                    
                    guard let longitudeRef = gpsDic[kCGImagePropertyGPSLongitudeRef as String] as? String else { return nil }
                    let longSign = ((longitudeRef == "E") ? 1 : -1)
                    longitude = CLLocationDegrees(Double(longSign) * Double(longitudeRaw))
                    
                    
                    
                    
                    guard let latitudeRaw = gpsDic[kCGImagePropertyGPSLatitude as String] as? Double else { return nil }
                    
                    
                    guard let latitudeRef = gpsDic[kCGImagePropertyGPSLatitudeRef as String] as? String else { return nil }
                    let latSign = ((latitudeRef == "N") ? 1 : -1)
                    latitude = CLLocationDegrees(Double(latSign) * Double(latitudeRaw))
                    
                    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                
                
            }
        }
        return nil
    }
    
}
