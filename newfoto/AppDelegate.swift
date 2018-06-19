//
//  AppDelegate.swift
//  newfoto
//
//  Created by Thomas Alexnat on 22.10.16.
//  Copyright © 2016 Thomas Alexnat. All rights reserved.
//

import UIKit
import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    

/*
    func myHandler(status: PHAuthorizationStatus) -> Void {
        NSLog("super handler")
    }
    */
  

    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      /*
        
        
        
        var assetCol: PHAssetCollection
        var myAsset: PHAsset
        var assetResult: PHFetchResult<PHAsset>
        var fetchOptions: PHFetchOptions = PHFetchOptions()
        // get all photos
        var allPhotos: PHFetchResult<PHAsset>!
        
        // get smart folders: smartFolder
        let myList: PHFetchResult<PHCollectionList> = PHCollectionList.fetchCollectionLists(with: PHCollectionListType.smartFolder,
                                                                                            subtype: PHCollectionListSubtype.any, options: nil)
        
        
        

        // Create a PHFetchResult object for each section in the table view.
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        // print("Alle Bilder \(   allPhotos.count)")
        // print("Retrieved smart folder collection \(myList)")

        
        
        // get smart folders: smartFolder
        let myAssetList: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: nil)
        
        


        // Photostream etc. Assets
        print("Retrieved asset collection \(myAssetList)")
        for item in 0..<myAssetList.count{
            print("item #\(item) is '\(myAssetList.object(at: item))'")
            
            assetCol  = myAssetList.object(at: item) as PHAssetCollection
            
           
    
            print("Number of Items in Asset Collection: \(assetCol.estimatedAssetCount)")
            assetResult = PHAsset.fetchAssets(in: assetCol, options: nil)
            
            print("Anzahl der Bilder: \( assetResult.count)")
    
        }
        

        
        */
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //  print("background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //    print("foreground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    
    
    

    
    

}

