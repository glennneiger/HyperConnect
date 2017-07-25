//
//  PhotoFeedModel.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation

class PhotoFeedModel: AnyObject {
    var title: String = ""
    var link: String = ""
    var description: String = ""
    var modified: Date? = nil
    var generator: String = ""
    var photos: [PhotoModel] = [PhotoModel]()
    
    init(json: [String: Any]) {
        if let value = json["title"] as? String {
            title = value
        }
        if let value = json["link"] as? String {
            link = value
        }
        if let value = json["description"] as? String {
            description = value
        }
        if let value = json["modified"] as? String {
            modified = Date.flickrDate(date: value)
        }
        if let value = json["generator"] as? String {
            generator = value
        }
        if let value = json["items"] as? [[String: Any]] {
            photos = value.flatMap { (raw) -> PhotoModel in
                let item = PhotoModel(json: raw)
                return item
            }
        }
    }
}
