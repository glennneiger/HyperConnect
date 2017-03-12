//
//  PhotoItemModel.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation

class PhotoItemModel: AnyObject {
    var title: String = ""
    var link: String = ""
    var media: [String: String] = [String: String]()
    var dateTaken: Date? = nil
    var description: String = ""
    var published: Date? = nil
    var author: String = ""
    var authorID: String = ""
    var tags: [String] = [String]()
    
    var imageURL: String? {
        get {
            return media["m"]
        }
    }
    
    init(json: [String: Any]) {
        if let value = json["title"] as? String {
            title = value
        }
        if let value = json["link"] as? String {
            link = value
        }
        if let value = json["media"] as? [String: String] {
            media = value
        }
        if let value = json["date_taken"] as? String {
            dateTaken = Date.flickrDate(date: value)
        }
        if let value = json["description"] as? String {
            description = value
        }
        if let value = json["published"] as? String {
            published = Date.flickrDate(date: value)
        }
        if let value = json["author"] as? String {
            author = value
        }
        if let value = json["author_id"] as? String {
            authorID = value
        }
        if let value = json["tags"] as? [String] {
            tags = value
        }
        
        
    }
}
