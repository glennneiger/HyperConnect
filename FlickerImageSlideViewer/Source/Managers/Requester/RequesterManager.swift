//
//  RequesterManager.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation
import Alamofire

final class RequesterManager {
    static let shareManager = RequesterManager()
    
    func requestPhotos(completion: @escaping (Bool, PhotoFeedModel?) -> Void) -> DataRequest? {
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"
        // https://www.flickr.com/services/api/response.json.html
        // 함수 래퍼를 지우려면 nojsoncallback=1 설정
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let request: DataRequest = Alamofire.request(url).responseJSON(queue: DispatchQueue.global(qos: .background), options: .allowFragments) { (response) in
            
            print("\(url)")
            
            // Background -> Main
            // UI Update Issue
            
            guard let urlResponse = response.response,
            let JSON = response.result.value as? [String: Any] else {
                    DispatchQueue.main.async { completion(false, nil) }
                    return
            }
            
            switch response.result {
            case .success:
                let photoFeed = PhotoFeedModel(json: JSON)
                DispatchQueue.main.async { completion(true, photoFeed) }
            case .failure(let error):
                print("Code: \(urlResponse.statusCode), \(error)")
                DispatchQueue.main.async { completion(false, nil) }
            }
        }
        
        return request
    }
}
