//
//  PhotoManager.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class PhotoManager {
    fileprivate static let photoManagerSharedInstance = PhotoManager()
    class func sharedManager() -> PhotoManager {
        return photoManagerSharedInstance
    }
    
    let requester = RequesterManager.sharedManager()
    var items = [PhotoItemModel]()
    var request: DataRequest? = nil
    var currentPhotoIndex = 0
    
    func getPhotoList(completion: @escaping (UIImage?) -> Void) {
        if items.count == 0 && request == nil {
            request = requester.requestPhotos(completion: { (success: Bool, photoFeed: PhotoFeedModel?) in
                if success, let photoFeed = photoFeed {
                    self.items.append(contentsOf: photoFeed.items)
                    self.fetchNextPhoto(completion: completion)
                    self.request = nil
                }
            })
        } else {
            fetchNextPhoto(completion: completion)
        }
    }
    
    func fetchNextPhoto(completion: @escaping (UIImage?) -> Void) {
        // 끝까지 봤으면 처음부터 다시
        if currentPhotoIndex >= items.count {
            currentPhotoIndex = 0
        }
        
        let first = items[currentPhotoIndex]
        
        guard let url = first.imageURL else {
            completion(nil)
            return
        }
        
        Alamofire.request(url).responseImage { (response) in
            self.currentPhotoIndex += 1
            
            guard let image = response.result.value else {
                completion(nil)
                return
            }
            
            completion(image)
        }
    }
}
