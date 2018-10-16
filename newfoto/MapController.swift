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

    fileprivate let mapRadius = 200.0

    @IBOutlet weak var previewImage: UIImageView!
    var album: AlbumDetail?
    
 //   fileprivate let mapThumbSize = CGSize(width: 240, height: 200)
    fileprivate let mapThumbSize = CGSize(width: 308, height: 308)
 //   fileprivate let mapThumbSizeSmall = CGSize(width: 80, height: 80)
  //  fileprivate let mapThumbSizeLarge = CGSize(width: 320, height: 200)
    
    fileprivate let previewSize = CGSize(width: 1920, height: 1080)
    
    
    //fileprivate let thumbnailSize =  CGSize(width: 160, height: 100)
    fileprivate let thumbnailSize =  CGSize(width: 308, height: 308)
    fileprivate let imageManager = PHImageManager()
    fileprivate let reuseIdentifier = "cell"
    fileprivate let clusterIdentifier = "photoCluster"
    
    
    // local identifier of ph asset
    fileprivate var selectedImage: String = ""
    
    // lookup if already an annotation coordinate exists
    fileprivate var annotationDic: [String: MKAnnotation] = [:]
    
    @IBOutlet weak var infoLabel: UILabel!
    
    // the map view to display all image positions
    @IBOutlet weak var mapView: focusMapView!
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
                        
                        // add a fix for orientation of the image
                        // with the RotationImage extension
                        // seems to be only with really fast loading
                        // images, sacrificing the orientation already rendered from UIKit...
                        cell.imageView.image = image.fixedOrientation()
                    }
                }
                
                // now check every image for GPS
                
                /*
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
                */
                
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
        
        
        buildImageLibrary()
        
        for assetMeta in assetMetas{
            let annotation = ImageAnnotation(coordinate: assetMeta.geoLocation!)
            annotation.phAsset = assetMeta.phAsset
            
            
            mapView.addAnnotation(annotation)
            
        }
        
        
        
        let menuPressRecognizer = UITapGestureRecognizer()
        menuPressRecognizer.addTarget(self, action: #selector(menuPressed(_:)) )
        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue)];
        mapView.addGestureRecognizer(menuPressRecognizer)
        

        
        
    }
    
    
    // make the collection view as environment first
    override var preferredFocusEnvironments: [UIFocusEnvironment]{

        return collectionView.preferredFocusEnvironments
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        // do we really have the album set from outside?
        guard let album = album else { return  }
        
        // already found coordinates
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // fetch the collection
        let assets = PHAsset.fetchAssets(in: album.assetCol, options: allPhotosOptions)
        

        
        // iterate over all assets and find image to center
        assets.enumerateObjects { (phAsset, index, stopBooleanPointer) in
            // just find the correct asset
            // sounds all like really bad performance
            // must be optimzed later to load from an array!
            if (index != indexPath.row) {
                return
            }
            
            if let annotation = self.annotationDic[phAsset.localIdentifier]{
                let regionRadius: CLLocationDistance = self.mapRadius
                
                
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(annotation.coordinate,
                                                                          regionRadius, regionRadius)
                
                
                
                self.mapView!.setRegion(coordinateRegion, animated: true)
                
                
                
                // SELECT ANNOTATION
                
                // already positioned on last click
                // then display detail image
                if(self.selectedImage == phAsset.localIdentifier){

                    // display detail image browser
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailController") as? DetailController{
                        print("Controller found")
                        var allAssets: [PHAsset] = []
                        // calculate the position
                        var rowNumber = indexPath.row
                        for sec in 0..<indexPath.section {
                            rowNumber = rowNumber + collectionView.numberOfItems(inSection: sec)
                        }
                        
                        controller.indexPosition = rowNumber
                        assets.enumerateObjects { (phAsset, index, stopBoolPointer) in
                            allAssets.append(phAsset)
                        }
                        
                        controller.photoAssets = allAssets
                        self.show(controller, sender: self)
                    }
                    
                    /*
                    _ = self.loadImage(asset: phAsset, isSynchronous: false){ imageData, dataUTI, orientation, infoArray in
                        
                        guard let imageData = imageData else { return }
 
                        if let image = UIImage(data: imageData){

                                self.previewImage.image = image

                                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                                    
                                    self.previewImage.bounds = CGRect(x: 550, y: 250, width: 800, height: 500)
                                    //  self.previewImage.frame =
                                    self.previewImage.layer.masksToBounds = false
                                    self.previewImage.layer.shadowOffset = CGSize(width:15, height:15);
                                    self.previewImage.layer.shadowRadius = 5;
                                    self.previewImage.layer.shadowOpacity = 0.5;
                                    self.previewImage.alpha = 1.0
                                    self.previewImage.clipsToBounds = false
                                    
                                }, completion: {
                                    (ended) -> Void in
                                    
                                })

                        }
                    }

                    */
                    
                    
                } else {
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.previewImage.frame = CGRect(x: (1920 / 2) - 50 , y: (1080 / 2) - 50, width: 100, height: 100)
                        self.previewImage.layer.shadowOffset = CGSize(width:15, height:15);
                        self.previewImage.layer.shadowRadius = 0
                        self.previewImage.layer.shadowOpacity = 0.0
                        self.previewImage.alpha = 0.0
                        
                        
                    }, completion: {
                        (ended) -> Void in
                        
                    })
                
                }
                
                self.selectedImage = phAsset.localIdentifier
            }
            else
            {
                // no location data - directly show the image
                // display detail image browser
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "DetailController") as? DetailController{
                    print("Controller found")
                    var allAssets: [PHAsset] = []
                    // calculate the position
                    var rowNumber = indexPath.row
                    for sec in 0..<indexPath.section {
                        rowNumber = rowNumber + collectionView.numberOfItems(inSection: sec)
                    }
                    
                    controller.indexPosition = rowNumber
                    assets.enumerateObjects { (phAsset, index, stopBoolPointer) in
                        allAssets.append(phAsset)
                    }
                    
                    controller.photoAssets = allAssets
                    self.show(controller, sender: self)
                }
            }
            
            
            
        }

        
        
        
        /*
                            
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
        */
        
        
        
        

        
        
    }
    
    
    
    /*
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
    */
 
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        print("asking for annotation view for map")

        // check if we have found a
        // image annotation data model
        // and set the image as annotation
        // but it might be to big :)
        
        
     //   notification.showMessage(message: "\(mapView.region.span)")
        
        
        
        if let imageAnnotation = annotation as? ImageAnnotation{
           // let annotationView = MKMarkerAnnotationView()
            let annotationView = SmartAnnotationView()
            //let annotationView = MKPinAnnotationView()
            
        
            //annotationView.glyphText = "📷"
        //    annotationView.titleVisibility = .hidden
        //    annotationView.subtitleVisibility = .hidden
        //    annotationView.displayPriority = .defaultHigh
            
        // clustering is allowed
           annotationView.clusteringIdentifier = clusterIdentifier
     
            
            
            
            // Request an image for the asset from the PHCachingImageManager.
            //  cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: imageAnnotation.phAsset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset.
                
                if(image==nil){
                    print("NIL image: fallback loaded")
                    annotationView.image = UIImage(named: "taxcloud_small")
                } else {
                    
                   // resizedImageWithinRect
                    
                    //let smallImage = self.imageWithImage(image: image!, scaledToSize: CGSize(width: 90, height: 90))
                    annotationView.image = image?.resizedImageWithinRect(rectSize: self.mapThumbSize )
                    annotationView.layer.masksToBounds = false;
                    annotationView.layer.shadowOffset = CGSize(width:15, height:15);
                    annotationView.layer.shadowRadius = 5;
                    annotationView.layer.shadowOpacity = 0.6;
                 //   annotationView.layer.cornerRadius = 16

                    annotationView.collisionMode = .circle
                    

                    
                }
            })
            
            
            
            /*
            
            _ = self.loadImage(asset: imageAnnotation.phAsset!, isSynchronous: true){ imageData, dataUTI, orientation, infoArray in
                
                guard let imageData = imageData else { return }
                
                if let image = UIImage(data: imageData){
                    annotationView.image = image
                  
                    
                    
                }
            }
            */
            
            return annotationView
            
         //   return annotationView
            
            
            
        }
        
        // check for clusters
        if let clusterAnnotation = annotation as? MKClusterAnnotation{
            print("found a cluster annotation")
            
            clusterAnnotation.title = "\(clusterAnnotation.memberAnnotations.count)"
            clusterAnnotation.subtitle = ""
            
            //let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: clusterIdentifier)
       //     let clusterView = MKAnnotationView(annotation: clusterAnnotation, reuseIdentifier: clusterIdentifier)
            
            
            
            // let clusterView = MKMarkerAnnotationView(annotation: clusterAnnotation, reuseIdentifier: clusterIdentifier)
            
            
            let clusterView = SmartMarkerAnnotationView()
            
            clusterView.titleVisibility = .hidden
            clusterView.subtitleVisibility = .hidden
            
            clusterView.glyphText = "\(clusterAnnotation.memberAnnotations.count)"
            //    clusterView.titleVisibility = .hidden
            
          //      clusterView.subtitleVisibility = .hidden
            //    annotationView.displayPriority = .defaultHigh
            
  
            // find the correct thumbnail for a cluster image
            // especially when selection a cluster annotation
            
            
            
            if let imageAnnotation = clusterAnnotation.memberAnnotations.first as? ImageAnnotation{
                
                // Request an image for the asset from the PHCachingImageManager.
                //  cell.representedAssetIdentifier = asset.localIdentifier
                imageManager.requestImage(for: imageAnnotation.phAsset!, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                    // The cell may have been recycled by the time this handler gets called;
                    // set the cell's thumbnail image only if it's still showing the same asset.
                    
                    if(image==nil){
                        print("NIL image: fallback loaded")
                        //clusterView.image = UIImage(named: "taxcloud_small")
                        
                    } else {
                        
                        // resizedImageWithinRect
                        
                        //let smallImage = self.imageWithImage(image: image!, scaledToSize: CGSize(width: 90, height: 90))
                        clusterView.image = image?.resizedImageWithinRect(rectSize: self.mapThumbSize )
                        clusterView.layer.masksToBounds = false;
                        clusterView.layer.shadowOffset = CGSize(width:15, height:15);
                        clusterView.layer.shadowRadius = 5;
                        clusterView.layer.shadowOpacity = 0.5;
                        clusterView.layer.cornerRadius = 16
                        
      clusterView.collisionMode = .circle
                        
                    }
                })
                
            }
            
       
            
            
            
            return clusterView
                    
        }
        
        
        return nil
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
  
    }


    @objc func menuPressed(_ recognizer: UIGestureRecognizer){
        print("menu pressed")
        // make the collection view as environment first
        
        
        mapView.refocus(focusEnvironments: collectionView.preferredFocusEnvironments)
     
        /*view.setNeedsFocusUpdate()
        view.updateFocusIfNeeded()
        */
        /*
        mapView.preferredFocusEnvironments = collectionView.preferredFocusEnvironments
        
        /*
        override var preferredFocusEnvironments: [UIFocusEnvironment]{
            
 return collectionView.preferredFocusEnvironments
        }
 */
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
        
        var assetsToGoCounter = 0
            
        // iterate over all assets
        assets.enumerateObjects { (phAsset, index, stopBooleanPointer) in
            // add asset meta
            
  //          _ = self.loadImage(asset: phAsset, isSynchronous: true){ imageData, dataUTI, orientation, infoArray in
                
            _ = self.loadImage(asset: phAsset, isSynchronous: false){ imageData, dataUTI, orientation, infoArray in
                
                assetsToGoCounter = assetsToGoCounter + 1
                
                if(assetsToGoCounter == assets.count){
                    DispatchQueue.main.async {
                        self.infoLabel.text = "All \(assetsToGoCounter) photos analyzed\nFound \(self.annotationDic.count) locations"
                    }

                }
                else {
                    DispatchQueue.main.async {
                        self.infoLabel.text = "Reading \(assets.count) photos\nAnalyzed \(assetsToGoCounter) and \(self.annotationDic.count) locations"
                    }

                }
                
                
                
                
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
                    
                    // self.assetMetas.append(assetMeta)
                    
                    let annotation = ImageAnnotation(coordinate: gpsLocation!)
                    annotation.phAsset = assetMeta.phAsset
                    assetMeta.geoLocation = gpsLocation
                    
                    self.annotationDic[phAsset.localIdentifier] = annotation
                    
                    self.mapView.addAnnotation(annotation)
                
                    
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






extension UIImage {
    
    
    
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height:newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        

        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}


class SmartAnnotationView: MKAnnotationView{
    
    open override var alignmentRectInsets: UIEdgeInsets{
    
        return UIEdgeInsets(top: 5, left: 50, bottom: 50, right: 5)
    }
}


class SmartMarkerAnnotationView: MKMarkerAnnotationView{
    
    open override var alignmentRectInsets: UIEdgeInsets{
        
        return UIEdgeInsets(top: 5, left: 50, bottom: 50, right: 5)
        
    }
}
