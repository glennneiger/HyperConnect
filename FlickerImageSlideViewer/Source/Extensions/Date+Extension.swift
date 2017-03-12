//
//  Date+Extension.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation

extension Date {
    static func dateRepresentation(date: String, dateFormat: String) -> Date? {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: date)
    }
    
    static func flickrDate(date: String) -> Date? {
        return Date.dateRepresentation(date: date, dateFormat: "yyyy-MM-dd'T'HH:mm:ssZ")
    }
}
