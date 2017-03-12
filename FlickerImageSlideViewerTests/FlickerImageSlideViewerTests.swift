//
//  FlickerImageSlideViewerTests.swift
//  FlickerImageSlideViewerTests
//
//  Created by Jaeyun,Oh on 2017. 3. 11..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import XCTest
@testable import FlickerImageSlideViewer

class FlickerImageSlideViewerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPhotoFeed() {
        let async = expectation(description: "get PhotoFeed")
        
        RequesterManager.sharedManager().requestPhotos { (success: Bool, photoFeed: PhotoFeedModel?) in
            XCTAssertFalse(success)
            XCTAssertNotNil(photoFeed)
            
            async.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testGetPhotoList() {
        let async = expectation(description: "get PhotoList")
        
        PhotoManager.sharedManager().getPhotoList { (image: UIImage?) in
            XCTAssertNotNil(image)
            async.fulfill()
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
