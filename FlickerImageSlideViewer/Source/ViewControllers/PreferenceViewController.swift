//
//  PreferenceViewController.swift
//  FlickerImageSlideViewer
//
//  Created by Jaeyun,Oh on 2017. 7. 23..
//  Copyright © 2017년 Jaeyun,Oh. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController {
    
    @IBOutlet weak var maxAutoDownloadPhotoCountControlSlider: UISlider!
    @IBOutlet weak var maxAutoDownloadPhotoCountLabel: UILabel!
    
    let photoManager = PhotoManager.sharedManager

    override func viewDidLoad() {
        super.viewDidLoad()

        maxAutoDownloadPhotoCountControlSlider.setValue(Float(photoManager.maxDownloadPhotoCount), animated: true)
        updateMaxAutoDownloadPhotoCountLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateMaxAutoDownloadPhotoCountLabel() {
        maxAutoDownloadPhotoCountLabel.text = "최대 저장 사진 수: \(photoManager.maxDownloadPhotoCount)"
    }
    
    //MARK: Event
    @IBAction func maxAutoDownloadPhotoCountIntervalChange(sender: UISlider) {
        let changeValue = Int(sender.value)
        
        var message: String? = nil
        if changeValue < photoManager.downloadPhotos.count {
            if changeValue < photoManager.lockedPhotos.count {
                message = "잠금된 사진수보다 작습니다. 저장된 사진이 지워질 수 있습니다."
            } else {
                message = "저장된 사진수보다 작습니다. 저장된 사진이 지워질 수 있습니다."
            }
        } else if changeValue < photoManager.lockedPhotos.count {
            message = "잠금된 사진수보다 작습니다. 저장된 사진이 지워질 수 있습니다."
        } else {
            photoManager.maxDownloadPhotoCount = changeValue
        }
        
        if let message = message {
            let alert = UIAlertController(title: "경고", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .destructive, handler: { (action) in
                self.photoManager.maxDownloadPhotoCount = changeValue
            })
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
                
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        updateMaxAutoDownloadPhotoCountLabel()
    }
    
    @IBAction func updateSlideShowAnimation(button: UIButton) {
        guard let animation = SlideShowAnimation(rawValue: button.tag) else {
            return
        }
        
        button.isSelected = !button.isSelected
        if button.isSelected {
            SlideShowPreference.sharedManager.appendSlideShowAnimation(animation: animation)
        } else {
            SlideShowPreference.sharedManager.removeSlideShowAnimation(animation: animation)
        }
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
