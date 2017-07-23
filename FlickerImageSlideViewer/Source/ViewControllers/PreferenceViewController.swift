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
    @IBOutlet weak var pageAnimationSegmentControl: UISegmentedControl!
    
    let photoManager = PhotoManager()

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
        
        photoManager.maxDownloadPhotoCount = changeValue
        updateMaxAutoDownloadPhotoCountLabel()
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
