//
//  Utils.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 23..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import UIKit

class Utils {
    class func applicationDocumentDirectory() -> URL? {
        guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return nil
        }
        
        return documentURL
    }
    
    // documentURL 을 정상적으로 얻어오지 못한 경우 throws 를 던지도록 해야함
    class func isFileExistAtDocument(fileName: String) -> Bool {
        guard let documentURL = applicationDocumentDirectory() else {
            return false
        }
        
        let documentFileURL = documentURL.appendingPathComponent(fileName)
        
        return isFileExist(at: documentFileURL)
    }
    
    class func isFileExist(at fileURL: URL) -> Bool {
        guard let documentURL = applicationDocumentDirectory() else {
            return false
        }
        
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    class func deleteFile(at fileURL: URL) -> Bool {
        guard Utils.isFileExist(at: fileURL) else {
            return false
        }
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
            
            return false
        }
        
        return true
    }
}
