//
//  PhotoManager.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Alamofire
import AlamofireImage

class PhotoManager {
    fileprivate static let photoManagerSharedInstance = PhotoManager()
    class func sharedManager() -> PhotoManager {
        return photoManagerSharedInstance
    }
    
    let prevDownloadCount = 4
    
    private var currentOnlinePhotoIndex = 0
    private var currentOfflinePhotoIndex = 0
    
    private let requester = RequesterManager.sharedManager()
    private var request: DataRequest? = nil
    private var downloadPhotos = [PhotoItemModel]()
    
    var maxDownloadPhotoCount = 4 {
        willSet(newValue) {
            if downloadPhotos.count < newValue {
                
            }
        }
    }
    
    func fetchNextPhoto(isOnline: Bool, completion: @escaping (UIImage?) -> Void) {
        completion(nil)
//        let currentIndex = self.currentIndex(isOnline: isOnline)
//        
//        if isOnline && currentIndex > downloadPhotos.count - prevDownloadCount {
//            self.getPhotoList(completion: { [weak self] (success) in
//                guard let strongSelf = self else {
//                    completion(nil)
//                    return
//                }
//                
//                if success {
//                    
//                } else {
//                    
//                }
//            })
//        } else {
//            let currentItem = downloadPhotos[currentIndex]
//            
//        }
//        let currentItem = downloadPhotos(self.currentIndex(isOnline: isOnline))
//        
//        guard let url = currentItem.imageURL else {
//            completion(nil)
//            return
//        }
//        
//        
//        
//        Alamofire.request(url).responseImage { (response) in
//            self.currentPhotoIndex += 1
//            
//            guard let image = response.result.value else {
//                completion(nil)
//                return
//            }
//            
//            completion(image)
//        }
    }
    
    private func getPhotoList(completion: @escaping (Bool) -> Void) {
        request = requester.requestPhotos( completion: { [weak self] (success: Bool, photoFeed: PhotoFeedModel?) in
            guard let strongSelf = self, success, let photoFeed = photoFeed else {
                completion(false)
                return
            }
            
            strongSelf.downloadPhotos.append(contentsOf: photoFeed.items)
            strongSelf.request = nil
            completion(true)
        })
    }
    
    private func downloadPhoto(imageURL: String, completion: @escaping (UIImage?) -> Void) {
        Alamofire.request(imageURL).responseImage { (response) in
            guard let image = response.result.value else {
                completion(nil)
                return
            }
            
            completion(image)
        }
    }
    
    private func currentIndex(isOnline: Bool) -> Int {
        // 끝까지 봤으면 처음부터 다시
        var photoIndex = 0
        
        if isOnline {
            if currentOnlinePhotoIndex >= downloadPhotos.count {
                currentOnlinePhotoIndex = 0
            }
            
            photoIndex = currentOnlinePhotoIndex
        } else {
            if currentOfflinePhotoIndex >= downloadPhotos.count {
                currentOfflinePhotoIndex = 0
            }
            
            photoIndex = currentOfflinePhotoIndex
        }
        
        return photoIndex
    }
    
//    func savePhoto() {
//        
//    }
//    
//    func deletePhoto() {
//        
//    }
//    
//    private deletePhoto()
}

//MARK:- Extension
//MARK: Save/Load
extension PhotoManager {
    fileprivate func documentPhotos() -> [URL] {
        guard let documentURL = Utils.applicationDocumentDirectory() else {
            return []
        }
        
        do {
            let documentPhotos = try FileManager.default.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            return documentPhotos
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    fileprivate func savePhotoToDocument(photoURL: URL?, savePhotoName: String) -> Bool {
        guard let photoURL = photoURL, let documentURL = Utils.applicationDocumentDirectory(), Utils.isFileExistAtDocument(fileName: savePhotoName) == false else {
            return false
        }
        
        let fileManager = FileManager.default
        
        let savePhotoURL = documentURL.appendingPathComponent(savePhotoName)
        
        do {
            try fileManager.copyItem(at: photoURL, to: savePhotoURL)
        } catch {
            print(error.localizedDescription)
            
            return false
        }
        
        return true
    }
    
    fileprivate func deletePhotoToDocument(photoName: String) -> Bool {
        guard let documentURL = Utils.applicationDocumentDirectory(), Utils.isFileExistAtDocument(fileName: photoName) else {
            return false
        }
        
        let fileManager = FileManager.default
        
        let storePhotoURL = documentURL.appendingPathComponent(photoName)
        
        do {
            try fileManager.removeItem(at: storePhotoURL)
        } catch {
            print(error.localizedDescription)
            
            return false
        }
        
        return true
    }
    
    fileprivate func savePhotoToAlbum(photoName: String) -> Bool {
        guard Utils.isFileExistAtDocument(fileName: photoName) == false else {
            return false
        }
        
        let photoURLs = documentPhotos()
        guard let photoURL = (photoURLs.filter { $0.lastPathComponent == photoName }.first), let photo = UIImage(contentsOfFile: photoURL.path) else {
            return false
        }
        
        savePhoto(photo: photo, photoName: photoName)
        
        return true
    }
}

//MARK:- Album
extension PhotoManager {
    fileprivate func savePhoto(photo: UIImage, photoName: String) {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            savePhoto(assetCollection: assetCollection, photo: photo, photoName: photoName)
            return
        } else {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
            } else {
                self.createAlbum()
            }
            
            if let assetCollection = fetchAssetCollectionForAlbum() {
                savePhoto(assetCollection: assetCollection, photo: photo, photoName: photoName)
            }
        }
    }
    
    private func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbum()
        } else {
            print("Allow Permission")
        }
    }
    
    private func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "flickerImageName")
        }) { (success, error) in
            if success {
                guard let _ = self.fetchAssetCollectionForAlbum() else {
                    return
                }
            }
        }
    }
    
    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = flickerImageAlbum")
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let firstObject = collection.firstObject {
            return firstObject
        }
        
        return nil
    }
    
    private func savePhoto(assetCollection: PHAssetCollection, photo: UIImage, photoName: String) {
        PHPhotoLibrary.shared().performChanges({ 
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: photo)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: assetCollection)
            
            if let assetPlaceholder = assetPlaceholder, let albumChangeRequest = albumChangeRequest {
                let enumeration: NSArray = [assetPlaceholder]
                albumChangeRequest.addAssets(enumeration)
            }
        }, completionHandler: nil)
    }
}
