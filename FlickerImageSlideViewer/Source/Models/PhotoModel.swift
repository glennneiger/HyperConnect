//
//  PhotoModel.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 25..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation

class PhotoModel : PhotoItemModel {
    var isLocking: Bool = false
    var isDownloadDone: Bool = false
    
    func saveFileURL() -> URL? {
        guard isDownloadDone, let saveFileName = self.saveFileName, let documentURL = Utils.applicationDocumentDirectory() else {
            return nil
        }
        
        return documentURL.appendingPathComponent(saveFileName)
    }
}
