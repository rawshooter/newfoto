//
//  SmartCollectionController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 09.04.17.
//  Copyright © 2017 Thomas Alexnat. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let headerIdentifier = "Header"

fileprivate let imageManager = PHImageManager()
//fileprivate let thumbnailSize =  CGSize(width: 616, height: 616)
fileprivate let thumbnailSize =  CGSize(width: 308, height: 308)
// fileprivate let thumbnailSize =  CGSize(width: 512, height: 512)

import Photos

// this class displays the photo stream in segments
// and other phasset collections
class SmartCollectionController: UICollectionViewController {

    
    // indicates if the photo collection should be grouped
    // by date or just a classic collection
    var groupByDate: Bool = false
    
    
    // indicator if the current photoset is in photostream mode
    // photo stream mode should get by default everytime a grouping by date
    var isPhotoStream: Bool = false
    
    
    // phfetch result of the current photos
    var allPhotos: PHFetchResult<PHAsset>?
    
    // the array of dateassets containing the assets for each date in a section
    // ordered in an accessible way via int
    var dateAssetsArray: [DateAssets] = []
    
    // the last position in the detail controller
    // if NIL no information available
    var lastIndexPosition: Int?

    // check when the controller is shown if we have access to the photo library
    override func viewDidAppear(_ animated: Bool) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status != PHAuthorizationStatus.authorized) {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "DisclaimerController") as? DisclaimerViewController{
                
                // show it on the highest level as a modal view
                // present(controller, animated: false, completion: nil)
                
                // show it on the highest level as a modal view
                //show(controller, sender: self)
                
                view.window?.rootViewController = controller
                
                
                // print("name of the presented view controller \(presentedViewController?.restorationIdentifier)")
                // print("Controller is shown")
                return
            }
        }
        
        print("Collection reappeared")
        updatePositionFromDetail()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
 
        if let path = getIndexPath(){
            
              collectionView?.scrollToItem(at: path, at: .centeredVertically, animated: false)
            //collectionView?.selectItem(at: path, animated: false, scrollPosition: .centeredVertically)
             collectionView?.layoutIfNeeded()
        }
  

        
    }
    func updatePositionFromDetail(){
        //collectionView?.reloadData()
        
        setNeedsFocusUpdate()
        //  updateFocusIfNeeded()
        
        // reset the lastIndexPosition
        // because we have already set and read out the position
        // and are ready for new details or viewcontroller changes
    
        
        // lastIndexPosition = nil
    }
    
    func getIndexPath() -> IndexPath?{
        if var lastIndex = lastIndexPosition{
            // calculate indexpath from photo array
            
            var sectionPosition = 0
            
            
            // no entries in the array?
            if(dateAssetsArray.count == 0){
                return nil
            }
            
            // iterate of the dateAssetsArray
            for item in dateAssetsArray {
                let dateAssets: DateAssets = item
                
                if(dateAssets.assetArray.count > lastIndex){
                    
                    
                    //print("coordinates row:\(lastIndex) section:\(sectionPosition)")
                    return IndexPath(row: lastIndex, section: sectionPosition)
                    
                }
                
                // move to the next date assets array
                sectionPosition += 1
                
                // remove the current count from the current lastindex position
                lastIndex = lastIndex - dateAssets.assetArray.count
                
            }
            
            // we didn´t finde the correct index
            return nil
            
        } else {
            // we had no last Path
            return nil
        }

    }
    
   
    override func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        //            print("lastIndex from View Controller \(lastIndexPosition)")
        return getIndexPath()
        
    }
    
 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            
            if(allPhotos == nil){
                print("loading photostream")
                
                // set photostream mode on, to treat photos in collection later different
                // from preference
                
                isPhotoStream = true
                
                let allPhotosOptions = PHFetchOptions()
                // ONLY fotostream is ascending - the rest is configurable
                allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
                
                // collectionView?.reloadData()
                
            }
            
            // put all the assets into the
            // needed sections
            prepareDateArray()
            collectionView?.reloadData()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // walk over already sorted assets
    // add for each new date a new array
    // add the subsequent assets
    func prepareDateArray(){
        
        if let assets = allPhotos{
            // iterate over all assets
            // set the UI to a progress info while
            
            // get current calendar
            let calendar  = NSCalendar.current
            
            // date of current section in the uicollection
            var currentSectionDate: Date?
            
            // holder for the current 
            // array of phasset objects in the current section
            var dateAssets: DateAssets?
            
            for index in 0..<assets.count{
                
                // get current photo
                let asset = assets.object(at: index)
  
                // get a safe creation date of the asset
                let creationDate: Date
                if let date = asset.creationDate{
                    creationDate = date
                } else {
                    // fallback if the asset had no
                    // date the. this might fall into
                    // a wrong section but then still
                    // no photo is lost which is important
                    creationDate = Date()
                }
  
                // inital state
                // we don´t have an container object for the assets
                // and not the current section date
                if(dateAssets == nil){
                    dateAssets = DateAssets(initDate: creationDate)
                    currentSectionDate = creationDate
                }
                
                
                
                
                
            
                var granularity: Calendar.Component
                
                if(SettingsController.isGroupByDateEnabled() || isPhotoStream){
                    granularity = Calendar.Component.day
                } else {
                    granularity = Calendar.Component.era
                }
                
                let isSameDay = calendar.isDate(currentSectionDate!,equalTo: creationDate, toGranularity: granularity)
                
                
                
                // on the same day
                // just append it to the asset container
                if(isSameDay){
                    dateAssets!.assetArray.append(asset)
                } else {
                    // add the new section to our
                    // overall array
                    dateAssetsArray.append(dateAssets!)
                    
                    // give us now a new dateAsset object
                    currentSectionDate = creationDate
                    dateAssets = DateAssets(initDate: currentSectionDate!)
                    
                    // and append the asset
                    dateAssets?.assetArray.append(asset)
                }
            
            }
            
            // finally add the last object 
            // if it exists
            if(dateAssets != nil){
                dateAssetsArray.append(dateAssets!)
            }
            
        
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // return the number of day sections in our collection
        return dateAssetsArray.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        // do we have any date entries?
        if(dateAssetsArray.isEmpty){
            return 0
        }
        
        // number of assets in the asset collection
        return dateAssetsArray[section].assetArray.count
        
        
    }

    
    

    
    
 
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view: HeaderView  = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath) as! HeaderView
        
        
        
        if(SettingsController.isGroupByDateEnabled() || isPhotoStream){
        
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            
            
            
            let date = dateAssetsArray[indexPath.section].date
            
            let dateStr = formatter.string(from: date)
            
            view.label.text = dateStr
            
        } else {
            view.label.text = "\(dateAssetsArray[indexPath.section].assetArray.count) Photos"
        }
        
        
        
        
        
        return view
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        // get the requestet asset at the position
        // check if the can obtain the image
        let asset: PHAsset = dateAssetsArray[indexPath.section].assetArray[indexPath.row]
        

        // Dequeue cell
        
        
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SmartCell {
            
            // use the indexpath as an unique identifier
            // to check for asny loading if this is the right cell
            cell.indexPath = indexPath
            
            
            
            
            
            // Request an image for the asset from the PHCachingImageManager.
            //  cell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                
                
                // The cell may have been recycled by the time this handler gets called;
                // set the cell's thumbnail image only if it's still showing the same asset
                if(cell.indexPath == indexPath){
                    
                    
                    if(image==nil){
                        print("NIL image: fallback loaded")
                        cell.imageView?.image = UIImage(named: "taxcloud_small")
                    } else {
                        // HERE WE SET THE IMAGE
                        cell.imageView?.image = image
                    }
                    
                    
                } else {
                    // INFO: Scrolloing was to fast for setting this image. Maybe this cell has alreay a newer image
                }
                
            })
            
            // TODO: WARNING Rasterization bakes all the layers
            // and cannot be moved individually
//            cell.layer.rasterizationScale = UIScreen.main.scale;
            
//            cell.layer.shouldRasterize = true;
            
            print("UIScreen.main.scale: \(UIScreen.main.nativeScale) and \(UIScreen.main.nativeBounds)")
            return cell
            
            
        }
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Configure the cell
        
        return cell
        
        
        
    }
    
    
    // check selection and push to detail view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath){
        print("selected element \(didSelectItemAt.item)")
        
        
        // no need to load a new storyboard. it already exists
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "DetailController") as? DetailController{
            print("Controller found")
            
            //self.present(controller, animated: true, completion: nil)
            // set the asset to display in the detail controller
            //controller.asset =  allPhotos.object(at: didSelectItemAt.item) as PHAsset
            
            // calculate the position
            var rowNumber = didSelectItemAt.row
            for sec in 0..<didSelectItemAt.section {
                rowNumber = rowNumber + collectionView.numberOfItems(inSection: sec)
            }
            

            
            controller.indexPosition = rowNumber
            
            
            var allAssets: [PHAsset] = []
            
            
            
            allPhotos!.enumerateObjects { (phAsset, index, stopBoolPointer) in
                allAssets.append(phAsset)
            }
            
            controller.photoAssets = allAssets
            
            
            
            //controller.collectionViewController = self
            
            //    print(didSelectItemAt)
            //    print(didSelectItemAt.item)
            
            // hand over this smart collection controller
            // this this controller can get back the
            // index position of the selected moved photo index
            
            controller.presentingSmartController = self
            self.show(controller, sender: self)
            
            //self.present(controller, animated: true, completion: nil)
            
        }
        
        
        
    }

    

}
