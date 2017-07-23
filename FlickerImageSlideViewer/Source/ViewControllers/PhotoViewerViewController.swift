//
//  PhotoViewerViewController.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 3. 12..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewerViewController: UIViewController {
    
    @IBOutlet weak var photoBaseView: UIView!
    @IBOutlet weak var slideShowIntervalControlSlider: UISlider!
    @IBOutlet weak var slideShowIntervalLabel: UILabel!
    
    static let prevPhotoCnt = 4
    
    var isRunning: Bool = false
    
    let photoManager = PhotoManager()
    var currentPhotoImageView: UIImageView? = nil
    
    var slideShowInterval: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyStyle()
        
        slideShowInterval = Int(slideShowIntervalControlSlider.value)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isRunning = true
        updatePhoto()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isRunning = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Internal
    private func applyStyle() {
        slideShowIntervalLabel.textColor = .green
    }
    
    private func updatePhoto() {
//        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
//        photoBaseView.addSubview(indicator)
        
        if isRunning == false {
            return
        }
        
        photoManager.fetchNextPhoto(isOnline: true) { (photo) in
            if let photo = photo {
                self.showNextPhoto(photo: photo)
            }
            
            // 성공여부와 관계없이 호출
            let deadline = DispatchTime.now() + DispatchTimeInterval.seconds(self.slideShowInterval)
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                self.updatePhoto()
            })
        }
    }
    
    private func showNextPhoto(photo: UIImage) {
        let photoImageView = UIImageView(image: photo)
        photoBaseView.addSubview(photoImageView)
        photoImageView.applyMarginConstraint(inset: .zero)
        
        photoImageView.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: { 
            if let currentPhotoImageView = self.currentPhotoImageView {
                currentPhotoImageView.alpha = 0.0
            }
            
            photoImageView.alpha = 1.0
        }, completion: { (completion) in
            if let currentPhotoImageView = self.currentPhotoImageView {
                currentPhotoImageView.removeFromSuperview()
            }
            
            self.currentPhotoImageView = photoImageView
        })
    }
    
    private func updateUI() {
        slideShowIntervalLabel.text = "\(slideShowInterval)초"
    }
    
    //MARK: Event
    @IBAction func slideShowIntervalChange(sender: UISlider) {
        let changeValue = Int(sender.value)
        slideShowInterval = changeValue
    }
}
