//
//  AlbumController.swift
//  newfoto
//
//  Created by Thomas Alexnat on 04.12.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "AlbumCell"

class AlbumController: UICollectionViewController {

    
    // collection of albums can be NIL
    var colAlbums: PHFetchResult<PHAssetCollection>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // we do not need to register since we have a storyboard that loaded all the stuff
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        getAlbums()
    }
    
    
    // retrieve all photo collections from the current user
    func getAlbums(){
        
        
        
        // get some collections: there are differnt types of collection lists
        
        
        
        
        
        // get smart folders: smartFolder
        
        // SmartFolder: Events, People
        /*
        let colFolders: PHFetchResult<PHCollectionList> = PHCollectionList.fetchCollectionLists(with: PHCollectionListType.smartFolder,
                                                                                           subtype: PHCollectionListSubtype.any, options: nil)
       */
        
        
        // empty?
        /*
        let colFolders: PHFetchResult<PHCollection> = PHCollectionList.fetchTopLevelUserCollections(with: nil)
       
        */
        
        
        //------  SMART ALBUMS: camera roll, panoramas, etc//
        /*
        let colSmartAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: nil)
   */
        
        
        
        //------  SMART ALBUMS: camera roll, panoramas, etc//
        
    colAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
        
        
        
        
        // EMTPY?
        /*
        let colFolders: PHFetchResult<PHCollectionList> = PHCollectionList.fetchCollectionLists(with: PHCollectionListType.folder,
                                                                                              subtype: PHCollectionListSubtype.any, options: nil)
     
        */
        

        

        
        for index in 0..<colAlbums!.count{
           
            colAlbums!.object(at: index)
            print("----------------")
            print("collection #\(index) is '\(colAlbums!.object(at: index) )'")
            print("----------------")
        }
        
        
        
        

        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    // return the number of albums we have
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        // return 0
    
        return colAlbums!.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get the custom album cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AlbumCell

    
        // get the album
        // get the asset collection of the selected album
        let assetCollection: PHAssetCollection = colAlbums!.object(at: indexPath.row)
        
        
        cell.subTitleLabel.text = "\(assetCollection.estimatedAssetCount) photos"
     
        
        
        //cell.subTitleLabel.text = "\(assetCollection.estimatedAssetCount) photos \(assetCollection.localizedLocationNames)"
        
        //        cell.subTitleLabel.text = "\(assetCollection.estimatedAssetCount) Bilder vom \(assetCollection.startDate) bis
        //(assetCollection.endDate)"
        
        
        cell.titleLabel.text = "\(assetCollection.localizedTitle!)"
        
        

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    
    
    
    
    // check selection and push to detail view
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath){
        print("selected element \(didSelectItemAt.item)")
        
        
        
        
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController{
            
            
            //self.present(controller, animated: true, completion: nil)
            // set the asset to display in the detail controller
            
            let assetCollection =  colAlbums!.object(at: didSelectItemAt.item) as! PHAssetCollection
            
            
            let assets = PHAsset.fetchAssets(in: assetCollection, options: nil)
            print("Number of Photos in selected collection: \(assets.count)")
            
            // give the controller all the needed assets
            controller.allPhotos = assets
            
           // controller.asset =  colAlbums.object(at: didSelectItemAt.item) as PHAssetCollection
            
            
            
            self.show(controller, sender: self)
            
            print("name of the presented view controller \(presentedViewController?.restorationIdentifier)")
            
        }
        
        
        
    }
    
    

    
    

}
