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

final class PhotoManager: AnyObject {
    static let sharedManager = PhotoManager()

    /**
        @brief 몇개 이전에 Pre-Download를 할지
    */
    
    var maxDownloadPhotoCount: Int = 4 {
        willSet {
            if downloadPhotos.count > newValue {
                // 변경된 값이 현재 저장되어있는 사진의 수보다 작다면 그에 맞춰 리사이징
                // Lock 된 사진들 우선순위를 더 높게
                _ = updatePhotos(maxCount: newValue)
            }
        }
    }
    
    var photoCount: Int {
        get {
            return photos.count
        }
    }
    
    var downloadPhotos: [PhotoModel] {
        get {
            return photos.filter { $0.isDownloadDone }
        }
    }
    
    var lockedPhotos: [PhotoModel] {
        get {
            return downloadPhotos.filter { $0.isLocking }
        }
    }
    
    private let prevDownloadCount = 4
    private var currentOnlinePhotoIndex = -1
    private var currentOfflinePhotoIndex = -1
    
    private let requester = RequesterManager.shareManager
    private var request: DataRequest? = nil
    fileprivate var photos = [PhotoModel]()
    
    // 껏다 켜도 동작되게...?
//    init() {
//        let documentURL = documentPhotos()
//        if documentURL.count > 0 {
//            documentURL.forEach({ (url) in
//                let photo = PhotoModel(json: ["": ""])
//                photo.storeFileURL = url
//                photos.append(photo)
//            })
//        }
//    }

    //MARK:- Interface
    func currentPhoto(isOnline: Bool) -> PhotoModel {
        let curIndex = currentIndex(isOnline: isOnline)
        if isOnline {
            return photos[curIndex]
        } else {
            return downloadPhotos[curIndex]
        }
    }
    
    func updateOfflinePhotoIndex(index: Int) {
        currentOfflinePhotoIndex = index
    }
    
    func photo(_ photo: PhotoModel, isLock: Bool) {
        photo.isLocking = isLock
    }
    
    func delete(photo: PhotoModel) -> Bool {
        guard let fileURL = photo.saveFileURL() else {
            return true
        }
        
        if Utils.deleteFile(at: fileURL) == false {
            return false
        }
        
        photo.isDownloadDone = false
        return true
    }
    
    func fetchNextPhoto(isOnline: Bool, completion: @escaping (UIImage?) -> Void) {
        nextIndex(isOnline: isOnline)
        let curIndex = currentIndex(isOnline: isOnline)

        // 온라인이면서 현재 보고있는 사진의 index가 전체 개수 - prevDownloadCount 보다 크다면 추가 다운로드
        if isOnline && curIndex > photos.count - prevDownloadCount {
            self.getPhotoList(completion: { [weak self] (success) in
                guard let weakSelf = self, success else {
                    completion(nil)
                    return
                }
                
                let nextPhoto = weakSelf.photos[curIndex]
                
                weakSelf.downloadPhoto(photo: nextPhoto, completion: { (image) in
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    
                    completion(image)
                })
            })
        } else {
            if isOnline {
                let nextPhoto = photos[curIndex]
                
                downloadPhoto(photo: nextPhoto, completion: { (image) in
                    guard let image = image else {
                        completion(nil)
                        return
                    }

                    completion(image)
                })
            } else {
                let nextPhoto = downloadPhotos[curIndex]
                
                guard let saveFileURL = nextPhoto.saveFileURL(), let image = UIImage(contentsOfFile: saveFileURL.path) else {
                    completion(nil)
                    return
                }
                
                completion(image)
            }
        }
    }
    
    //MARK:- Internal
    private func getPhotoList(completion: @escaping (Bool) -> Void) {
        request = requester.requestPhotos( completion: { [weak self] (success: Bool, photoFeed: PhotoFeedModel?) in
            guard let weakSelf = self, success, let photoFeed = photoFeed else {
                completion(false)
                return
            }

            weakSelf.photos.append(contentsOf: photoFeed.photos)
            completion(true)
            weakSelf.request = nil
        })
    }
    
    private func downloadPhoto(photo: PhotoModel, completion: @escaping (UIImage?) -> Void) {
        guard let imageURL = photo.imageURL,
              let saveFileName = photo.saveFileName,
              let url = URL(string: imageURL),
              let documentURL = Utils.applicationDocumentDirectory() else {
            completion(nil)
            return
        }
        
        let dest: DownloadRequest.DownloadFileDestination = { _, _ in
            return (documentURL.appendingPathComponent(saveFileName), [.createIntermediateDirectories, .removePreviousFile])
        }
        
        Alamofire.download(url, to: dest).response { [weak self] (response) in
            guard let weakSelf = self, response.error == nil, let dstURL = response.destinationURL else {
                completion(nil)
                return
            }
            
            let image = UIImage(contentsOfFile: dstURL.path)
            if weakSelf.autoUpdatePhotoToDocument(withPhoto: photo) == false {
                print("Auto-Update Failed")
            }
            
            completion(image)
        }
    }
    
    private func currentIndex(isOnline: Bool) -> Int {
        var photoIndex = 0
        
        if isOnline {
            photoIndex = currentOnlinePhotoIndex
        } else {
            photoIndex = currentOfflinePhotoIndex
        }
        
        return photoIndex
    }
    
    private func nextIndex(isOnline: Bool) {
        // 끝까지 봤으면 처음부터 다시
        
        if isOnline {
            currentOnlinePhotoIndex += 1
            
            if currentOnlinePhotoIndex >= photos.count {
                currentOnlinePhotoIndex = 0
            }
        } else {
            currentOfflinePhotoIndex += 1
            
            if currentOfflinePhotoIndex >= (downloadPhotos.count) {
                currentOfflinePhotoIndex = 0
            }
        }
    }

    fileprivate func updatePhotos(maxCount: Int? = nil, photo: PhotoModel? = nil) -> Bool {
        let maxCount = maxCount ?? maxDownloadPhotoCount
        
        if maxCount > downloadPhotos.count {
            if let photo = photo {
                photo.isDownloadDone = true
            }
        } else {
            var remain = downloadPhotos.count - (maxCount - 1)
            for downloadPhoto in downloadPhotos {
                if downloadPhoto.isLocking == false {
                    if delete(photo: downloadPhoto) {
                        remain -= 1
                        
                        if remain <= 0 {
                            break
                        }
                    }
                }
            }
            
            if remain > 0 {
                for lockedPhoto in lockedPhotos {
                    if delete(photo: lockedPhoto) {
                        remain -= 1
                        if remain <= 0 {
                            break
                        }
                    }
                }
            }
            
            if remain <= 0 {
                if let photo = photo {
                    photo.isDownloadDone = true
                }
                
                return true
            } else {
                if let photo = photo {
                    _ = delete(photo: photo)
                }
                
                return false
            }
        }
        
        return true
    }
}

//MARK:- Extension
//MARK: Save/Load
extension PhotoManager {
    func documentPhotos() -> [URL] {
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
    
    // 내부에서 자동으로 계산하여 Save, Delete 를 해준다.
    fileprivate func autoUpdatePhotoToDocument(withPhoto: PhotoModel) -> Bool {
        return updatePhotos(maxCount: nil, photo: withPhoto)
    }
    
//    private func savePhotoToDocument(tempPhotoURL: URL) -> Bool {
//        guard let documentURL = Utils.applicationDocumentDirectory(), Utils.isFileExistAtDocument(fileName: photoName) == false else {
//            return false
//        }
//        
//        let fileManager = FileManager.default
//        
//        let savePhotoURL = documentURL.appendingPathComponent(photoName)
//        
//        do {
//            try fileManager.copyItem(at: photoURL, to: savePhotoURL)
//        } catch {
//            print(error.localizedDescription)
//            
//            return false
//        }
//        
//        return true
//    }
    
//    fileprivate func deletePhotoToDocument(photoURL: String) -> Bool {
//        guard let documentURL = Utils.applicationDocumentDirectory(), Utils.isFileExistAtDocument(fileName: photoName) else {
//            return false
//        }
//        
//        let fileManager = FileManager.default
//        
//        let storePhotoURL = documentURL.appendingPathComponent(photoName)
//        
//        do {
//            try fileManager.removeItem(at: storePhotoURL)
//        } catch {
//            print(error.localizedDescription)
//            
//            return false
//        }
//        
//        return true
//    }
    
    public func savePhotoToAlbum(photoName: String) -> Bool {
        guard Utils.isFileExistAtDocument(fileName: photoName) else {
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
        UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
        
//        if let assetCollection = fetchAssetCollectionForAlbum() {
//            savePhoto(assetCollection: assetCollection, photo: photo, photoName: photoName)
//            return
//        } else {
//            if PHPhotoLibrary.authorizationStatus() != .authorized {
//                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
//            } else {
//                self.createAlbum()
//            }
//            
//            if let assetCollection = fetchAssetCollectionForAlbum() {
//                savePhoto(assetCollection: assetCollection, photo: photo, photoName: photoName)
//            }
//        }
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
