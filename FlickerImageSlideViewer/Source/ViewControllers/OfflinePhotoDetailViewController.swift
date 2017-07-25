//
//  OfflinePhotoDetailViewController.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 23..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import UIKit

class OfflinePhotoDetailViewController: UIViewController {
    @IBOutlet weak var photoBaseView: UIImageView!
    
    @IBOutlet weak var photoLockButton: UIButton!
    @IBOutlet weak var photoSaveButton: UIButton!
    @IBOutlet weak var photoDeleteButton: UIButton!
    
    var isRunning: Bool = false
    
    var beginPhotoIndex: Int = 0
    let photoManager = PhotoManager.sharedManager
    var currentPhotoImageView: UIImageView? = nil
    
    let slideShowInterval: Int = 3

    override func viewDidLoad() {
        super.viewDidLoad()

//        if photoManager.downloadPhotos.count < beginPhotoIndex {
//            beginPhotoIndex = -1
//        }
        
        photoManager.updateOfflinePhotoIndex(index: beginPhotoIndex - 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isRunning = true
        updatePhoto()
        
        if let naviController = self.navigationController {
            naviController.setNavigationBarHidden(false, animated: animated)
        }
        
        if let tabBar = self.tabBarController {
            tabBar.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isRunning = false
        
        if let tabBar = self.tabBarController {
            tabBar.tabBar.isHidden = false
        }
    }
    
    private func updatePhoto() {
        if isRunning == false {
            return
        }
        
        photoManager.fetchNextPhoto(isOnline: false) { (photo) in
            if let photo = photo {
                self.showNextPhoto(photo: photo)
            }
            
            // 성공여부와 관계없이 호출
            let deadline = DispatchTime.now() + DispatchTimeInterval.seconds(self.slideShowInterval)
            DispatchQueue.main.asyncAfter(deadline: deadline, execute: { [weak self]  in
                if let weakSelf = self {
                    if weakSelf.photoManager.downloadPhotos.count > 1 {
                        weakSelf.updatePhoto()
                    }
                }
            })
        }
    }
    
    private func showNextPhoto(photo: UIImage) {
        let photoImageView = UIImageView(image: photo)
        photoBaseView.addSubview(photoImageView)
        photoImageView.applyMarginConstraint(inset: .zero)
        
        if let animation = SlideShowPreference.sharedManager.randomEffect() {
            switch animation {
            case .LeftTop: photoImageView.transform = CGAffineTransform(translationX: -photoImageView.frame.width, y: -photoImageView.frame.height)
            case .RightBottom: photoImageView.transform = CGAffineTransform(translationX: photoImageView.frame.width, y: photoImageView.frame.height)
            case .Left: photoImageView.transform = CGAffineTransform(translationX: -photoImageView.frame.width, y: 0)
            case .Right: photoImageView.transform = CGAffineTransform(translationX: photoImageView.frame.width, y: 0)
            case .Up: photoImageView.transform = CGAffineTransform(translationX: 0, y: -photoImageView.frame.height)
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                photoImageView.transform = .identity
            }, completion: { (completion) in
                if let currentPhotoImageView = self.currentPhotoImageView {
                    currentPhotoImageView.removeFromSuperview()
                }
                self.currentPhotoImageView = photoImageView
            })
        } else {
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
    }
    
    func updateStatusButtons() {
        // 해당 포토의 설정값에 따라 상태 버튼들 업데이트
        
        let photo = photoManager.currentPhoto(isOnline: false)
        photoLockButton.isSelected = photo.isLocking
    }
    
    @IBAction func photoLockButtonDidPushed(button: UIButton) {
        button.isSelected = !button.isSelected
        
        let photo = photoManager.currentPhoto(isOnline: false)
        photoManager.photo(photo, isLock: button.isSelected)
    }
    
    @IBAction func photoSaveButtonDidPushed(button: UIButton) {
        let photo = photoManager.currentPhoto(isOnline: false)
        guard let saveFileName = photo.saveFileName else {
            return
        }

        _ = photoManager.savePhotoToAlbum(photoName: saveFileName)
    }
    
    @IBAction func photoDeleteButtonDidPushed(button: UIButton) {
        
        let photo = photoManager.currentPhoto(isOnline: false)
        _ = photoManager.delete(photo: photo)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
