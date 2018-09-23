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

class MapController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    fileprivate let mapRadius = 700.0

    var album: AlbumDetail?
    
    fileprivate let thumbnailSize =  CGSize(width: 320, height: 200)
    fileprivate let imageManager = PHImageManager()
    fileprivate let reuseIdentifier = "cell"
    fileprivate let clusterIdentifier = "photoCluster"
    
    // lookup if already an annotation coordinate exists
    fileprivate var annotationDic: [Int: MKAnnotation] = [:]
    
    
    // the map view to display all image positions
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // array with the identified assets containing
    // location infos
    var assetMetas: [AssetMetadata] = []
    
    // notification view to display messages
    let notification: NotificationView = NotificationView()
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // do we really have the album set from outside?
        guard let album = album else { return 0 }
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        // fetch the collection
        let assets = PHAsset.fetchAssets(in: album.assetCol, options: allPhotosOptions)
        return assets.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! mapThumbnailCell
        
        // just save the current index path
        // when we are called async to check if we
        // really loaded the correct image
        cell.indexPath = indexPath
        
        
        
        
        cell.imageView.image = UIImage(named: "taxcloud_hd")
        
        
        // load the image for the cell async
        
        
        
        
        
        // do we really have the album set from outside?
        guard let album = album else { return cell }
        
        
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
            // just find the correct asset
            // sounds all like really bad performance
            // must be optimzed later to load from an array!
            if (index != indexPath.row) {
                return
            }
            
            _ = self.loadImage(asset: phAsset, isSynchronous: false){ imageData, dataUTI, orientation, infoArray in
                
                guard let imageData = imageData else { return }
                
                
                if let image = UIImage(data: imageData){
                    if(cell.indexPath?.row == index){
                        cell.imageView.image = image
                    }
                }
                
                // now check every image for GPS
                
                if ( self.annotationDic[indexPath.row] == nil){
                    
                    
                    var gpsLocation: CLLocationCoordinate2D?
                    
                    // take a shortcut and try to obtain a location
                    if(phAsset.location?.coordinate != nil){
                        print("asset location found \(phAsset.creationDate ?? nil) location \(phAsset.location!)")
                        gpsLocation = phAsset.location!.coordinate
                    }
                    
                    // or via the image data
                    if let location = self.getGPSCoordinates(imageData: imageData){
                        print("exif location found \(phAsset.creationDate ?? nil) location \(location)")
                        gpsLocation = location
                    }
                    
                    if( gpsLocation != nil){
                        // oh we did get a gps coordinate
                        
                        
                        
                        let assetMeta = AssetMetadata(phAsset: phAsset)
                        //   assetMeta.thumbnail = image
                        
                        
                        let annotation = ImageAnnotation(coordinate: gpsLocation!)
                        annotation.phAsset = assetMeta.phAsset
                        assetMeta.geoLocation = gpsLocation
                        
                        // check if via async the annotation was set already
                        if (self.annotationDic[indexPath.row] == nil){
                            self.annotationDic[indexPath.row] = annotation
                            self.mapView.addAnnotation(annotation)
                        }
                        
                        
                        
                        //self.assetMetas.append(assetMeta)
                    }
                }
                
                
            }
        }
        
        
        
        
        return cell
    }
    
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        
        
    }
    
    
    // make the collection view as environment first
    override var preferredFocusEnvironments: [UIFocusEnvironment]{

        return collectionView.preferredFocusEnvironments
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        // do we really have the album set from outside?
        guard let album = album else { return  }
        
        // already found coordinates
        if let annotation = self.annotationDic[indexPath.row]{
            let regionRadius: CLLocationDistance = self.mapRadius
            
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                                                                      regionRadius, regionRadius)
            self.mapView!.setRegion(coordinateRegion, animated: true)
  //          self.mapView.selectedAnnotations = [annotation]
            self.mapView.selectedAnnotations = Array(self.annotationDic.values)
            return
        }
        
                            
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
            // just find the correct asset
            // sounds all like really bad performance
            // must be optimzed later to load from an array!
            if (index != indexPath.row) {
                return
            }
            
            _ = self.loadImage(asset: phAsset, isSynchronous: false){ imageData, dataUTI, orientation, infoArray in
                
                guard let imageData = imageData else { return }
                
  
                // now check every image for GPS
                
                var gpsLocation: CLLocationCoordinate2D?
                
                // take a shortcut and try to obtain a location
                if(phAsset.location?.coordinate != nil){
                    print("asset location found \(phAsset.creationDate ?? nil) location \(phAsset.location!)")
                    gpsLocation = phAsset.location!.coordinate
                }
                
                // or via the image data
                if let location = self.getGPSCoordinates(imageData: imageData){
                    print("exif location found \(phAsset.creationDate ?? nil) location \(location)")
                    gpsLocation = location
                }
                
                if( gpsLocation != nil){
                    // oh we did get a gps coordinate
                    
                    let assetMeta = AssetMetadata(phAsset: phAsset)
                    let annotation = ImageAnnotation(coordinate: gpsLocation!)
                    annotation.phAsset = assetMeta.phAsset
                    assetMeta.geoLocation = gpsLocation
                    
                    
                    // check if via async the annotation was set already
                    if (self.annotationDic[indexPath.row] == nil){
                        self.annotationDic[indexPath.row] = annotation
                        self.mapView.addAnnotation(annotation)
                    } else {
                        self.mapView.selectedAnnotations = [self.annotationDic[indexPath.row]!]
                    }
                    
                    
                    // zoom of map in meters
                    let regionRadius: CLLocationDistance = self.mapRadius
                    
                    
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(gpsLocation!,
                                                                              regionRadius, regionRadius)
                    self.mapView!.setRegion(coordinateRegion, animated: true)
                
                }
            }
            
            
        }
        
        
        
        
        

        
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        
        
        

        
        
        if let cell = context.nextFocusedView as? UICollectionViewCell {
        
            if let indexPath = collectionView.indexPath(for: cell) {
            
                
                // already found coordinates
                if let annotation = self.annotationDic[indexPath.row]{
                    let regionRadius: CLLocationDistance = self.mapRadius
                    
                    
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                                                                              regionRadius, regionRadius)
                    self.mapView!.setRegion(coordinateRegion, animated: true)
                     self.mapView.selectedAnnotations = [annotation]
                    return
                }
                
                // do we really have the album set from outside?
                guard let album = album else { return  }
                
                
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
                    // just find the correct asset
                    // sounds all like really bad performance
                    // must be optimzed later to load from an array!
                    if (index != indexPath.row) {
                        return
                    }
                    
                    _ = self.loadImage(asset: phAsset, isSynchronous: false){ imageData, dataUTI, orientation, infoArray in
                        
                        guard let imageData = imageData else { return }
                        
                        
                        // now check every image for GPS
                        
                        var gpsLocation: CLLocationCoordinate2D?
                        
                        // take a shortcut and try to obtain a location
                        if(phAsset.location?.coordinate != nil){
                            print("asset location found \(phAsset.creationDate ?? nil) location \(phAsset.location!)")
                            gpsLocation = phAsset.location!.coordinate
                        }
                        
                        // or via the image data
                        if let location = self.getGPSCoordinates(imageData: imageData){
                            print("exif location found \(phAsset.creationDate ?? nil) location \(location)")
                            gpsLocation = location
                        }
                        
                        if( gpsLocation != nil){
                            // oh we did get a gps coordinate
                            
                            let assetMeta = AssetMetadata(phAsset: phAsset)
                            let annotation = ImageAnnotation(coordinate: gpsLocation!)
                            annotation.phAsset = assetMeta.phAsset
                            assetMeta.geoLocation = gpsLocation
                            
                            
                            // check if via async the annotation was set already
                            if (self.annotationDic[indexPath.row] == nil){
                                self.annotationDic[indexPath.row] = annotation
                                
                                
                                
                                self.mapView.addAnnotation(annotation)
                            } else {
                                self.mapView.selectedAnnotations = [self.annotationDic[indexPath.row]!]
                            }
                            
                            
                            
                            // zoom of map in meters
                            let regionRadius: CLLocationDistance = self.mapRadius
                            
                            
                            let coordinateRegion = MKCoordinateRegionMakeWithDistance(gpsLocation!,
                                                                                      regionRadius, regionRadius)
                            self.mapView!.setRegion(coordinateRegion, animated: true)
                            
                        }
                    }
                    
                    
                }
                
                
                
                
                
                
                
            }
            
        }

    }
    
 
    
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("asking for annotation view for map")

        // check if we have found a
        // image annotation data model
        // and set the image as annotation
        // but it might be to big :)
        if let imageAnnotation = annotation as? ImageAnnotation{
            let annotationView = MKMarkerAnnotationView()
            
        
            annotationView.glyphText = "📷"
            annotationView.titleVisibility = .hidden
            annotationView.subtitleVisibility = .hidden
            annotationView.displayPriority = .defaultHigh
            
        // clustering is allowed
           annotationView.clusteringIdentifier = clusterIdentifier
     
            
            
           /*
            _ = self.loadImage(asset: imageAnnotation.phAsset!, isSynchronous: true){ imageData, dataUTI, orientation, infoArray in
                
                guard let imageData = imageData else { return }
                
                if let image = UIImage(data: imageData){
                    annotationView.glyphImage = image
                }
            }
            */
        
            
            return annotationView
            
         //   return annotationView
            
            
            
        }
        
        // check for clusters
        if let clusterAnnotation = annotation as? MKClusterAnnotation{
            print("found a cluster annotation")
            
            clusterAnnotation.title = ""
            clusterAnnotation.subtitle = ""
            
            let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: clusterIdentifier)
            
  
            
            
            return clusterView
                    
        }
        
        
        return nil
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        /*
        notification.showMessage(message: "Building Geo Locations")
   
        buildImageLibrary()
       notification.showMessage(message: "Found \(assetMetas.count) Locations")
        
        
        
        
        for assetMeta in assetMetas{
            let annotation = ImageAnnotation(coordinate: assetMeta.geoLocation!)
            annotation.phAsset = assetMeta.phAsset
            

            mapView.addAnnotation(annotation)
            
        }
        */
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
            
  //          _ = self.loadImage(asset: phAsset, isSynchronous: true){ imageData, dataUTI, orientation, infoArray in
                
            _ = self.loadImage(asset: phAsset, isSynchronous: false){ imageData, dataUTI, orientation, infoArray in
                
                guard let imageData = imageData else { return }
      
                
                // now check every image for GPS
                
                var gpsLocation: CLLocationCoordinate2D?
                
                // take a shortcut and try to obtain a location
                if(phAsset.location?.coordinate != nil){
                    print("asset location found \(phAsset.creationDate ?? nil) location \(phAsset.location!)")
                    gpsLocation = phAsset.location!.coordinate
                }
                
                // or via the image data
                if let location = self.getGPSCoordinates(imageData: imageData){
                    print("exif location found \(phAsset.creationDate ?? nil) location \(location)")
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
